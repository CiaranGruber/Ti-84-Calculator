using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public class Warp
    {
        private byte offset;
        private byte map;
        private byte x;
        private byte y;

        public Warp()
        {
            offset = 0;
            map = 0;
            x = 0;
            y = 0;
        }

        public Warp(BinaryReader reader)
        {
            offset = reader.ReadByte();
            map = reader.ReadByte();
            x = reader.ReadByte();
            y = reader.ReadByte();
        }

        public byte Offset
        {
            get => offset;
            set => offset = value;
        }
        public byte Map
        {
            get => map;
            set => map = value;
        }
        public byte X
        {
            get => x;
            set => x = value;
        }
        public byte Y
        {
            get => y;
            set => y = value;
        }

        public byte[] ToArray()
        {
            List<byte> data = new List<byte>();
            data.Add(offset);
            data.Add(map);
            data.Add(x);
            data.Add(y);

            return data.ToArray();
        }

        public void Clear()
        {
            offset = 0;
            map = 0;
            x = 0;
            y = 0;
        }

        public void CopyFrom(Warp warp)
        {
            this.offset = warp.Offset;
            this.map = warp.Map;
            this.x = warp.X;
            this.y = warp.Y;
        }

        public void WriteCsv(TextWriter textWriter)
        {
            textWriter.Write(offset + "," + map + "," + x + "," + y + ",");
        }
    }
}
