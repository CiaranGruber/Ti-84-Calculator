using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    class HuffNode
    {
        public bool IsBranch;
        public byte Symbol;
        public int Weight;
        public HuffNode Left;
        public HuffNode Right;

        public HuffNode(byte symbol)
        {
            IsBranch = false;
            Symbol = symbol;
            Weight = 1;
            Left = Right = null;
        }

        public HuffNode(int weight, HuffNode left, HuffNode right)
        {
            IsBranch = true;
            Symbol = 0;
            Weight = weight;
            Left = left;
            Right = right;
        }

        public void Traverse(List<byte> chars, List<bool> tree, List<HuffCode> huffCodes, List<bool> path)
        {
            if (IsBranch)
            {
                tree.Add(true);
                List<bool> leftPath = new List<bool>(path);
                leftPath.Add(false);
                List<bool> rightPath = new List<bool>(path);
                rightPath.Add(true);
                Left.Traverse(chars, tree, huffCodes, leftPath);
                Right.Traverse(chars, tree, huffCodes, rightPath);
            }
            else
            {
                chars.Add(Symbol);
                tree.Add(false);
                huffCodes.Add(new HuffCode(Symbol, path));
            }
        }
    }
}
