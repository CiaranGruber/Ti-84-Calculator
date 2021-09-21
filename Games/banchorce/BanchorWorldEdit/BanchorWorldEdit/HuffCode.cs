using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public class HuffCode
    {
        public byte Symbol;
        public List<bool> HashString;

        public HuffCode(byte symbol, List<bool> hashString)
        {
            Symbol = symbol;
            HashString = hashString;
        }

    }
}
