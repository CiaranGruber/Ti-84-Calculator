using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public static class Huffman
    {
        /*
         * UnPack
         *  Decode a file from a stream of Huffman encoded data
         * 
         * byte[] archive = encoded data
         * int fileNum = file # to decode
         */
        public static byte[] UnPack(byte[] archive, int fileNum)
        {
            int numFiles = archive[1];
            int numChars = (archive[2] << 8) | archive[3];

            // read file info
            int dataOffset = archive[4 + (fileNum * 6)] << 8 | archive[5 + (fileNum * 6)]; // index in archive[] that data starts from
            int bitShift = archive[7 + (fileNum * 6)];
            byte dataBitMask = (byte)(0x01 << bitShift);
            int length = archive[8 + (fileNum * 6)] << 8 | archive[9 + (fileNum * 6)];

            // build tree
            int charOffset = 4 + (6 * numFiles); // index in archive[] that characters start from (DE)
            int treeOffset = charOffset + numChars; // index in archive[] that tree starts from (HL)
            ushort[] tree = new ushort[512]; // 512 elements to build tree
            ushort treeIndex = 0; // index in tree[] (IX)
            List<ushort> stack = new List<ushort>(); // stack for treeIndex
            int charCount = numChars - 1;
            byte treeBitMask = 0x01;
            while (true)
            {
                // UncrunchTree
                if ((treeBitMask & archive[treeOffset]) != 0)
                {
                    // Branch
                    stack.Add(treeIndex);
                    treeIndex++;
                }
                else
                {
                    // NoBranch
                    tree[treeIndex] = (ushort)(0xFF00 | archive[charOffset]);
                    charOffset++;
                    treeIndex++;
                    if (charCount == 0)
                        break;
                    tree[stack[stack.Count - 1]] = treeIndex;
                    stack.RemoveAt(stack.Count - 1);
                    charCount--;
                }
                // NextTreeBit
                if ((treeBitMask & 0x80) != 0)
                    treeOffset++;
                treeBitMask = (byte)(treeBitMask << 1 | treeBitMask >> 7);
            }

            // unpack the data
            List<byte> data = new List<byte>();
            while (true)
            {
                // UncrunchData
                treeIndex = 0;
                while (true)
                {
                    // CheckTree
                    if (((byte)(tree[treeIndex] >> 8)) != 0xFF)
                    {
                        if ((dataBitMask & archive[dataOffset]) == 0)
                            // LeftBranch
                            treeIndex++;
                        else
                            // RightBranch
                            treeIndex = tree[treeIndex];
                        // NextDataBit
                        if ((dataBitMask & 0x80) != 0)
                            dataOffset++;
                        dataBitMask = (byte)(dataBitMask << 1 | dataBitMask >> 7);
                    }
                    else
                    {
                        break;
                    }
                }
                // EndOfBranch
                data.Add((byte)tree[treeIndex]);
                length--;
                if (length == 0)
                    break;
            }

            return data.ToArray();
        }


        /*
         * Pack
         *  Encode 1 or more byte streams into a Huffman archive
         * 
         * List<byte[]> files = List of byte streams (files)
         */
        public static byte[] Pack(List<byte[]> files)
        {
            int numFiles = files.Count;

            // scan files to get symbols and their respective weights
            List<HuffNode> nodes = new List<HuffNode>();
            for (int i = 0; i < files.Count; i++)
            {
                for (int j = 0; j < files[i].Length; j++)
                {
                    if (nodes.Count == 0)
                        nodes.Add(new HuffNode(files[i][j]));
                    else
                    {
                        bool nodeFound = false;
                        for (int n = 0; n < nodes.Count; n++)
                            if (nodes[n].Symbol == files[i][j])
                            {
                                nodes[n].Weight++;
                                nodeFound = true;
                                break;
                            }
                        if (!nodeFound)
                            nodes.Add(new HuffNode(files[i][j]));
                    }
                }
            }

            // sort the Nodes into a priority queue (in ascending weight order)
            nodes.Sort((x, y) => x.Weight.CompareTo(y.Weight));

            // build tree
            while (nodes.Count > 1)
            {
                HuffNode left = nodes[0];
                HuffNode right = nodes[1];
                int weight = nodes[0].Weight + nodes[1].Weight;
                nodes.RemoveRange(0, 2);
                HuffNode branch = new HuffNode(weight, left, right);
                int n = 0;
                while (n < nodes.Count)
                {
                    if (branch.Weight <= nodes[n].Weight)
                        break;
                    n++;
                }
                nodes.Insert(n, branch);
            }

            // traverse tree and write it, also saving the hash codes for each symbol
            List<byte> chars = new List<byte>();
            List<bool> tree = new List<bool>();
            List<HuffCode> huffCodes = new List<HuffCode>();
            nodes[0].Traverse(chars, tree, huffCodes, new List<bool>());

            // initialise byte stream that will eventually be returned
            List<byte> stream = new List<byte>();
            
            // write # files
            stream.Add(0);
            stream.Add((byte)numFiles);

            // write # chars
            stream.Add((byte)(chars.Count >> 8));
            stream.Add((byte)chars.Count);

            // write file headers & prepare data
            List<bool> data = new List<bool>();
            foreach (byte[] file in files)
            {
                // write byte offset
                ushort offset = (ushort)(2 + 2 + (6 * numFiles) + chars.Count + Math.Ceiling(((decimal)tree.Count) / 8) + (data.Count / 8));
                byte msb = (byte)(offset >> 8);
                byte lsb = (byte)(offset & 0x00FF);
                stream.Add(msb);
                stream.Add(lsb);
                // write bit offset
                lsb = (byte)(data.Count % 8);
                stream.Add(0);
                stream.Add(lsb);
                // write unpacked data length
                ushort len = (ushort)file.Length;
                msb = (byte)(len >> 8);
                lsb = (byte)(len & 0x00FF);
                stream.Add(msb);
                stream.Add(lsb);
                // process each byte in the file and write the packed hash
                foreach (byte symbol in file)
                {
                    foreach (HuffCode huffCode in huffCodes)
                    {
                        if (symbol == huffCode.Symbol)
                        {
                            data.AddRange(huffCode.HashString);
                            break;
                        }
                    }
                }
            }

            // write chars
            stream.AddRange(chars);

            // write tree
            stream.AddRange(bitsToBytes(tree));

            // write data
            stream.AddRange(bitsToBytes(data));

            return stream.ToArray();
        }


        /*
         * bitsToBytes
         *  Convert a List of bools to an array of bytes
         * 
         * List<bool> bits = List of bits
         */
        private static byte[] bitsToBytes(List<bool> bits)
        {
            List<byte> bytes = new List<byte>();
            byte mask = 0x01;

            foreach (bool bit in bits)
            {
                if (mask == 0x01)
                    bytes.Add(0);
                if (bit)
                    bytes[bytes.Count - 1] |= mask;
                mask = (byte)(mask << 1 | mask >> 7);
            }

            return bytes.ToArray();
        }
    }
}
