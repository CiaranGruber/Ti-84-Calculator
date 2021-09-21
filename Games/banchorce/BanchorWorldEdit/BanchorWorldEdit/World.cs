using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BanchorWorldEdit
{
    public class World
    {
        public const byte MAX_CHESTS = 100;
        public const byte MAX_MAPS = 255;
        public const byte MAX_ENEMY_ID = 35;

        public const int HUFFMAN_OFFSET = 1 + (MAX_CHESTS * Chest.CHEST_SIZE);

        private string fileName;
        private byte numMaps;
        private List<Chest> chests;
        private List<Map> maps;

        // exportPng variables
        private int[,] exportMaps = new int[256, 3];
        private int xMin, xMax, yMax;
        private int[] exportBranch = new int[256];

        public World()
        {
            fileName = "";
            numMaps = 1;
            chests = new List<Chest>();
            maps = new List<Map>();
            for (int i = 0; i < MAX_CHESTS; i++)
                chests.Add(new Chest());
            maps.Add(new Map());
        }

        public World(string path)
        {
            fileName = path;
            BinaryReader reader = new BinaryReader(File.Open(fileName + ".rpg", FileMode.Open));
            numMaps = reader.ReadByte();

            // read chests
            chests = new List<Chest>();
            for (int c = 0; c < MAX_CHESTS; c++)
                chests.Add(new Chest(reader));

            // rest of the file is the Huffman archive
            byte[] archive = reader.ReadBytes((int)reader.BaseStream.Length - HUFFMAN_OFFSET);
            maps = new List<Map>();
            for (int m = 0; m < numMaps; m++)
            {
                byte[] file = Huffman.UnPack(archive, m);
                maps.Add(new Map(file));
            }

            reader.Close();
        }

        public string FileName => fileName;
        public byte NumMaps => numMaps;

        public void Save()
        {
            BinaryWriter writer = new BinaryWriter(File.Open(fileName + ".rpg", FileMode.Create));

            // write numMaps and all chest data (uncompressed)
            writer.Write(numMaps);
            for (int i = 0; i < MAX_CHESTS; i++)
                chests[i].Save(writer);

            // compress maps and write them
            List<byte[]> files = new List<byte[]>();
            for (int m = 0; m < numMaps; m++)
                files.Add(maps[m].ToArray());
            byte[] archive = Huffman.Pack(files);
            writer.Write(archive);

            writer.Close();
        }

        public void Save(string path)
        {
            fileName = path;
            Save();
        }

        public bool Validate()
        {
            // validate maps
            for (int m = 0; m < numMaps; m++)
            {
                // check map connections
                if (maps[m].MapUp != 255)
                {
                    if (maps[m].MapUp >= numMaps)
                    {
                        MessageBox.Show("Map #" + m + ".MapUp connects to invalid map", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                    if (maps[maps[m].MapUp].MapDown != m)
                    {
                        MessageBox.Show("Map #" + m + ".MapUp is a one way connection", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }
                if (maps[m].MapDown != 255)
                {
                    if (maps[m].MapDown >= numMaps)
                    {
                        MessageBox.Show("Map #" + m + ".MapDown connects to invalid map", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                    if (maps[maps[m].MapDown].MapUp != m)
                    {
                        MessageBox.Show("Map #" + m + ".MapDown is a one way connection", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }
                if (maps[m].MapLeft != 255)
                {
                    if (maps[m].MapLeft >= numMaps)
                    {
                        MessageBox.Show("Map #" + m + ".MapLeft connects to invalid map", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                    if (maps[maps[m].MapLeft].MapRight != m)
                    {
                        MessageBox.Show("Map #" + m + ".MapLeft is a one way connection", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }
                if (maps[m].MapRight != 255)
                {
                    if (maps[m].MapRight >= numMaps)
                    {
                        MessageBox.Show("Map #" + m + ".MapRight connects to invalid map", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                    if (maps[maps[m].MapRight].MapLeft != m)
                    {
                        MessageBox.Show("Map #" + m + ".MapRight is a one way connection", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }

                // check warps
                for (int w = 0; w < maps[m].NumWarps; w++)
                {
                    Warp warp = maps[m].GetWarp(w);
                    if (warp.Map >= numMaps && warp.Map != 255)
                    {
                        MessageBox.Show("Map #" + m + " has a Warp with an invalid destination", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return false;
                    }
                }
            }

            return true;
        }

        public void AddMap()
        {
            if (numMaps < MAX_MAPS)
            {
                maps.Add(new Map());
                numMaps++;
            }
        }

        public void InsertMap(byte mapNum)
        {
            if (numMaps < MAX_MAPS)
            {
                // update chests
                for (int c = 0; c < MAX_CHESTS; c++)
                {
                    Chest chest = chests[c];
                    if (chest.Map >= mapNum && chest.Map != 255)
                        // if chest is on a higher map, shift the map #
                        chest.Map++;
                }

                // update map connections and warps
                for (int m = 0; m < numMaps; m++)
                {
                    Map map = maps[m];
                    if (map.MapUp >= mapNum && map.MapUp != 255)
                        map.MapUp++;
                    if (map.MapDown >= mapNum && map.MapDown != 255)
                        map.MapDown++;
                    if (map.MapLeft >= mapNum && map.MapLeft != 255)
                        map.MapLeft++;
                    if (map.MapRight >= mapNum && map.MapRight != 255)
                        map.MapRight++;
                    for (int w = 0; w < map.NumWarps; w++)
                    {
                        Warp warp = map.GetWarp(w);
                        if (warp.Map >= mapNum && warp.Map != 255)
                            warp.Map++;
                    }
                }

                // insert new map and inc counter
                Map newMap = new Map();
                maps.Insert(mapNum, newMap);
                numMaps++;
            }
        }

        public void DeleteMap(byte mapNum)
        {
            if (numMaps > 1)
            {
                // make sure there are no connections or warps to this map
                for (int m = 0; m < numMaps; m++)
                {
                    Map map = maps[m];
                    if (map.MapUp == mapNum)
                    {
                        MessageBox.Show("Map #" + m + ".MapUp connects to this map!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    if (map.MapDown == mapNum)
                    {
                        MessageBox.Show("Map #" + m + ".MapDown connects to this map!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    if (map.MapLeft == mapNum)
                    {
                        MessageBox.Show("Map #" + m + ".MapLeft connects to this map!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    if (map.MapRight == mapNum)
                    {
                        MessageBox.Show("Map #" + m + ".MapRight connects to this map!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                    for (int w = 0; w < map.NumWarps; w++)
                    {
                        Warp warp = map.GetWarp(w);
                        if (warp.Map == mapNum)
                        {
                            MessageBox.Show("Map #" + m + " has a Warp to this map!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                            return;
                        }
                    }
                }

                // update chests
                for (int c = 0; c < MAX_CHESTS; c++)
                {
                    Chest chest = chests[c];
                    if (chest.Map == mapNum)
                        // if chest is on deleted map, clear chest entry
                        chest.Clear();
                    if (chest.Map >= mapNum && chest.Map != 255)
                        // if chest is on a higher map, shift the map #
                        chest.Map--;
                }

                // delete map from the list
                maps.RemoveAt(mapNum);

                // dec map counter
                numMaps--;

                // update map connections and warps
                for (int m = 0; m < numMaps; m++)
                {
                    Map map = maps[m];
                    if (map.MapUp > mapNum && map.MapUp != 255)
                        map.MapUp--;
                    if (map.MapDown > mapNum && map.MapDown != 255)
                        map.MapDown--;
                    if (map.MapLeft > mapNum && map.MapLeft != 255)
                        map.MapLeft--;
                    if (map.MapRight > mapNum && map.MapRight != 255)
                        map.MapRight--;
                    for (int w = 0; w < map.NumWarps; w++)
                    {
                        Warp warp = map.GetWarp(w);
                        if (warp.Map > mapNum && warp.Map != 255)
                            warp.Map--;
                    }
                }
            }
        }

        public Chest GetChest(int c)
        {
            return chests[c];
        }

        public Chest GetChest(int mapNum, int x, int y)
        {
            byte offset = (byte)((y * Map.MAP_WIDTH) + x);
            for (int i = 0; i < MAX_CHESTS; i++)
                if (chests[i].Map == mapNum && chests[i].Offset == offset)
                    return chests[i];
            return null;
        }

        public bool CheckForChest(int mapNum, int x, int y)
        {
            byte offset = (byte)((y * Map.MAP_WIDTH) + x);
            for (int i = 0; i < MAX_CHESTS; i++)
                if (chests[i].Map == mapNum && chests[i].Offset == offset)
                    return true;
            return false;
        }

        public int FindEmptyChestSlot()
        {
            int i;
            for (i = 0; i < MAX_CHESTS; i++)
                if (chests[i].IsEmpty())
                    break;
            return i;
        }

        public void RemoveChest(int mapNum, int x, int y)
        {
            // find the chest
            byte offset = (byte)((y * Map.MAP_WIDTH) + x);
            int chestId;
            for (chestId = 0; chestId < MAX_CHESTS; chestId++)
                if (chests[chestId].Map == mapNum && chests[chestId].Offset == offset)
                    break;
            // if found, overwrite down the chain and clear the last warp
            if (chestId < MAX_CHESTS)
            {
                for (int i = chestId; i < (MAX_CHESTS - 1); i++)
                    chests[i].CopyFrom(chests[i + 1]);
                chests[MAX_CHESTS - 1].Clear();
            }
        }

        public Map GetMap(int m)
        {
            return maps[m];
        }

        public void ExportToPng(Bitmap tileset, bool gridFlag)
        {
            for (int i = 0; i < 256; i++)
                exportMaps[i, 0] = 0;
            xMin = 0;
            xMax = -2;
            yMax = 0;

            while (findNewBranch() != -1)
            {
                clearBranch();
                exportScan(findNewBranch(), xMax + 2, 0);
                xMin = xMax + 2;
            }

            Bitmap mapImage = new Bitmap((xMax + 1) * (Map.MAP_WIDTH * 16), (yMax + 1) * (Map.MAP_HEIGHT * 16));
            for (int m = 0; m < numMaps; m++)
            {
                for (int y = 0; y < Map.MAP_HEIGHT; y++)
                {
                    for (int x = 0; x < Map.MAP_WIDTH; x++)
                    {
                        int t = maps[m].GetTile(x, y);
                        int tx = t % 16;
                        int ty = t / 16;
                        Bitmap tileImage = tileset.Clone(new Rectangle(tx * 32, ty * 32, 32, 32), tileset.PixelFormat);
                        Bitmap smallTileImage = new Bitmap(16, 16);
                        using (Graphics g = Graphics.FromImage(smallTileImage))
                        {
                            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.NearestNeighbor;
                            g.DrawImage(tileImage, 0, 0, 16, 16);
                        }
                        using (Graphics g = Graphics.FromImage(mapImage))
                        {
                            g.DrawImage(smallTileImage, (exportMaps[m, 1] * Map.MAP_WIDTH * 16) + (x * 16), (exportMaps[m, 2] * Map.MAP_HEIGHT * 16) + (y * 16));
                        }
                    }
                }
                if (gridFlag)
                {
                    using (Graphics g = Graphics.FromImage(mapImage))
                    {
                        g.DrawRectangle(new Pen(Color.White), exportMaps[m, 1] * Map.MAP_WIDTH * 16, exportMaps[m, 2] * Map.MAP_HEIGHT * 16, (Map.MAP_WIDTH * 16) - 1, (Map.MAP_HEIGHT * 16) - 1);
                    }
                }
            }

            if (!gridFlag)
                mapImage.Save(fileName + ".png", ImageFormat.Png);
            else
                mapImage.Save(fileName + "_grid.png", ImageFormat.Png);
        }

        private void exportScan(int m, int x, int y)
        {
            // check that this map isn't already being scanned
            if (exportMaps[m, 0] == 1) return;
            // check that x isn't less than 0 or xMin
            if (x < 0)
            {
                moveBranchRight();
                x = 0;
            }
            if (x < xMin)
            {
                moveBranchRight();
                x = xMin;
            }
            // check that y isn't less than 0
            if (y < 0)
            {
                moveBranchDown();
                y = 0;
            }
            // add map to branch
            addToBranch(m);
            // check maxes
            if (x > xMax) { xMax = x; }
            if (y > yMax) { yMax = y; }
            // set work flag, x & y coords
            exportMaps[m, 0] = 1;
            exportMaps[m, 1] = x;
            exportMaps[m, 2] = y;
            if (maps[m].MapUp != 255) { exportScan(maps[m].MapUp, x, y - 1); }
            x = exportMaps[m, 1];
            y = exportMaps[m, 2];
            if (maps[m].MapDown != 255) { exportScan(maps[m].MapDown, x, y + 1); }
            x = exportMaps[m, 1];
            y = exportMaps[m, 2];
            if (maps[m].MapLeft != 255) { exportScan(maps[m].MapLeft, x - 1, y); }
            x = exportMaps[m, 1];
            y = exportMaps[m, 2];
            if (maps[m].MapRight != 255) { exportScan(maps[m].MapRight, x + 1, y); }
        }

        private void clearBranch()
        {
            for (int i = 0; i < 256; i++)
                exportBranch[i] = -1;
        }

        private int findNewBranch()
        {
            for (int m = 0; m < numMaps; m++)
            {
                if (exportMaps[m, 0] == 0) { return m; }
            }
            return -1;
        }

        private void addToBranch(int m)
        {
            int i = 0;
            while (exportBranch[i] != -1) { i++; }
            exportBranch[i] = m;
        }

        private void moveBranchDown()
        {
            int i = 0;
            while (exportBranch[i] != -1)
            {
                exportMaps[exportBranch[i], 2]++;
                i++;
            }
        }

        private void moveBranchRight()
        {
            int i = 0;
            while (exportBranch[i] != -1)
            {
                exportMaps[exportBranch[i], 1]++;
                i++;
            }
        }

        public void ExportToCsv()
        {
            TextWriter textWriter;

            textWriter = new StreamWriter(File.Open(fileName + "_chests.csv", FileMode.Create));
            Chest.WriteCsvHeader(textWriter);
            for (int c = 0; c < MAX_CHESTS; c++)
                chests[c].WriteCsv(textWriter);
            textWriter.Close();

            textWriter = new StreamWriter(File.Open(fileName + "_mapdata.csv", FileMode.Create));
            Map.WriteCsvHeader(textWriter);
            for (int m = 0; m < numMaps; m++)
                maps[m].WriteCsv(textWriter, m);
            textWriter.Close();
        }

        public void ImportChestData(string csvName)
        {
            TextReader textReader = new StreamReader(File.Open(csvName, FileMode.Open));
            List<List<byte>> dataset = CsvReader.ParseByteArray(textReader);
            textReader.Close();

            if (dataset != null)
            {
                if (dataset.Count == MAX_CHESTS)
                {
                    for (int c = 0; c < MAX_CHESTS; c++)
                    {
                        chests[c].Map = dataset[c][0];
                        chests[c].Offset = dataset[c][1];
                        chests[c].ItemId = dataset[c][2];
                    }
                }
                else
                    MessageBox.Show("Invalid number of CHEST entries!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
                MessageBox.Show("Non-byte information contained in CSV file!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public void ImportTileIDs(string csvName)
        {
            TextReader textReader = new StreamReader(File.Open(csvName, FileMode.Open));
            List<List<byte>> dataset = CsvReader.ParseByteArray(textReader);
            textReader.Close();

            if (dataset != null)
            {
                // sort by old tile ID
                dataset.Sort((x, y) => x[0].CompareTo(y[0]));

                // process all maps
                for (int m = 0; m < numMaps; m++)
                {
                    Map map = maps[m];
                    for (int y = 0; y < Map.MAP_HEIGHT; y++)
                        for (int x = 0; x < Map.MAP_WIDTH; x++)
                        {
                            byte tile = map.GetTile(x, y);
                            if (tile < dataset.Count)
                                map.SetTile(x, y, dataset[tile][1]);
                        }
                }
            }
            else
                MessageBox.Show("Non-byte information contained in CSV file!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public void ImportMapIDs(string csvName)
        {
            TextReader textReader = new StreamReader(File.Open(csvName, FileMode.Open));
            List<List<byte>> dataset = CsvReader.ParseByteArray(textReader);
            textReader.Close();

            if (dataset != null)
            {
                if (dataset.Count == numMaps)
                {
                    List<Map> newMaps = new List<Map>();

                    // sort by old map ID and reassign connecting & warp map IDs
                    dataset.Sort((x, y) => x[0].CompareTo(y[0]));
                    for (int m = 0; m < numMaps; m++)
                    {
                        if (maps[m].MapUp!= 255)
                            maps[m].MapUp = dataset[maps[m].MapUp][1];
                        if (maps[m].MapDown != 255)
                            maps[m].MapDown = dataset[maps[m].MapDown][1];
                        if (maps[m].MapLeft != 255)
                            maps[m].MapLeft = dataset[maps[m].MapLeft][1];
                        if (maps[m].MapRight != 255)
                            maps[m].MapRight = dataset[maps[m].MapRight][1];
                        for (int w = 0; w < maps[m].NumWarps; w++)
                        {
                            Warp warp = maps[m].GetWarp(w);
                            if (warp.Map != 255)
                                warp.Map = dataset[warp.Map][1];
                        }
                    }
                    // reassign chest map IDs
                    for (int c = 0; c < MAX_CHESTS; c++)
                    {
                        if (chests[c].Map != 255)
                            chests[c].Map = dataset[chests[c].Map][1];
                    }

                    // sort by new map ID and add to new List
                    dataset.Sort((x, y) => x[1].CompareTo(y[1]));
                    foreach (List<byte> record in dataset)
                        newMaps.Add(maps[record[0]]);

                    maps = newMaps;
                }
                else
                    MessageBox.Show("Invalid number of MAP entries!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            else
                MessageBox.Show("Non-byte information contained in CSV file!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }

        public void ImportMapMetaData(string csvName)
        {
            TextReader textReader = new StreamReader(File.Open(csvName, FileMode.Open));
            List<List<byte>> dataset = CsvReader.ParseByteArray(textReader);
            textReader.Close();

            if (dataset != null)
                foreach (List<byte> record in dataset)
                    maps[record[0]].ImportMetaData(record);
            else
                MessageBox.Show("Non-byte information contained in CSV file!", "", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
