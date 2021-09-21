using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public static class CsvReader
    {
        public static List<List<byte>> ParseByteArray(TextReader textReader)
        {
            List<string[]> textData = new List<string[]>();
            string str;
            while ((str = textReader.ReadLine()) != null)
                textData.Add(str.Split(new char[] { ',' }));

            List<List<byte>> data = new List<List<byte>>();
            int i = 0;
            foreach (string[] line in textData)
            {
                data.Add(new List<byte>());
                foreach (string cell in line)
                {
                    byte value;
                    if (!Byte.TryParse(cell, out value))
                        return null;
                    data[i].Add(value);
                }
                i++;
            }

            return data;
        }
    }
}
