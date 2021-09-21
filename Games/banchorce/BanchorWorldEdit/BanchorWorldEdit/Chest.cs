using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public class Chest
    {
        public const int CHEST_SIZE = 3;

        private byte map;
        private byte offset;
        private byte itemId;

        public Chest()
        {
            map = 255;
            offset = 0;
            itemId = 0;
        }

        public Chest(BinaryReader reader)
        {
            map = reader.ReadByte();
            offset = reader.ReadByte();
            itemId = reader.ReadByte();
        }

        public byte Map
        {
            get => map;
            set => map = value;
        }
        public byte Offset
        {
            get => offset;
            set => offset = value;
        }
        public byte ItemId
        {
            get => itemId;
            set => itemId = value;
        }

        public void Save(BinaryWriter writer)
        {
            writer.Write(map);
            writer.Write(offset);
            writer.Write(itemId);
        }

        public void Clear()
        {
            map = 255;
            offset = 0;
            itemId = 0;
        }

        public void CopyFrom(Chest chest)
        {
            this.map = chest.Map;
            this.offset = chest.Offset;
            this.itemId = chest.ItemId;
        }

        public bool IsEmpty()
        {
            if (map == 255)
                return true;
            else
                return false;
        }

        public static void WriteCsvHeader(TextWriter textWriter)
        {
            textWriter.WriteLine("MAP,OFFSET,CHEST_ID");
        }

        public void WriteCsv(TextWriter textWriter)
        {
            textWriter.WriteLine(map + "," + offset + "," + itemId);
        }
    }
}
