using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public class Person
    {
        private byte offset;
        private byte talkId;

        public Person()
        {
            offset = 0;
            talkId = 0;
        }

        public Person(BinaryReader reader)
        {
            offset = reader.ReadByte();
            talkId = reader.ReadByte();
        }

        public byte Offset
        {
            get => offset;
            set => offset = value;
        }
        public byte TalkId
        {
            get => talkId;
            set => talkId = value;
        }

        public byte[] ToArray()
        {
            List<byte> data = new List<byte>();
            data.Add(offset);
            data.Add(talkId);

            return data.ToArray();
        }

        public void Clear()
        {
            offset = 0;
            talkId = 0;
        }

        public void CopyFrom(Person person)
        {
            this.offset = person.Offset;
            this.talkId = person.TalkId;
        }

        public void WriteCsv(TextWriter textWriter)
        {
            textWriter.Write(offset + "," + talkId + ",");
        }
    }
}
