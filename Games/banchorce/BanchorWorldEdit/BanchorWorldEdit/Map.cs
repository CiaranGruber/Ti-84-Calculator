using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public class Map
    {
        public const int MAP_WIDTH = 16;
        public const int MAP_HEIGHT = 12;
        public const int MAX_WARPS = 4;
        public const int MAX_PEOPLE = 4;

        private byte[,] tiles = new byte[MAP_WIDTH, MAP_HEIGHT];
        private byte mapUp, mapDown, mapLeft, mapRight;
        private byte numWarps;
        private List<Warp> warps;
        private byte numPeople;
        private List<Person> people;
        private byte enemyId;
        private byte areaId;

        public Map()
        {
            for (int x = 0; x < MAP_WIDTH; x++)
                for (int y = 0; y < MAP_HEIGHT; y++)
                    tiles[x, y] = 0;
            mapUp = 255;
            mapDown = 255;
            mapLeft = 255;
            mapRight = 255;
            numWarps = 0;
            warps = new List<Warp>();
            for (int i = 0; i < MAX_WARPS; i++)
                warps.Add(new Warp());
            people = new List<Person>();
            for (int i = 0; i < MAX_PEOPLE; i++)
                people.Add(new Person());
            numPeople = 0;
            enemyId = 0;
            areaId = 0;
        }

        public Map(byte[] data)
        {
            BinaryReader reader = new BinaryReader(new MemoryStream(data));
            for (int y = 0; y < MAP_HEIGHT; y++)
                for (int x = 0; x < MAP_WIDTH; x++)
                    tiles[x, y] = reader.ReadByte();
            mapUp = reader.ReadByte();
            mapDown = reader.ReadByte();
            mapLeft = reader.ReadByte();
            mapRight = reader.ReadByte();
            numWarps = reader.ReadByte();
            warps = new List<Warp>();
            for (int i = 0; i < MAX_WARPS; i++)
                warps.Add(new Warp(reader));
            people = new List<Person>();
            numPeople = reader.ReadByte();
            for (int i = 0; i < MAX_PEOPLE; i++)
                people.Add(new Person(reader));
            enemyId = reader.ReadByte();
            areaId = reader.ReadByte();
        }

        public byte MapUp
        {
            get => mapUp;
            set => mapUp = value;
        }
        public byte MapDown
        {
            get => mapDown;
            set => mapDown = value;
        }
        public byte MapLeft
        {
            get => mapLeft;
            set => mapLeft = value;
        }
        public byte MapRight
        {
            get => mapRight;
            set => mapRight = value;
        }
        public byte NumWarps => numWarps;
        public byte NumPeople => numPeople;
        public byte EnemyId
        {
            get => enemyId;
            set => enemyId = value;
        }
        public byte AreaId
        {
            get => areaId;
            set => areaId = value;
        }

        public static byte CalcOffset(int x, int y)
        {
            return (byte)((y * MAP_WIDTH) + x);
        }

        public byte[] ToArray()
        {
            List<byte> data = new List<byte>();
            for (int y = 0; y < MAP_HEIGHT; y++)
                for (int x = 0; x < MAP_WIDTH; x++)
                    data.Add(tiles[x, y]);
            data.Add(mapUp);
            data.Add(mapDown);
            data.Add(mapLeft);
            data.Add(mapRight);
            data.Add(numWarps);
            for (int w = 0; w < MAX_WARPS; w++)
                data.AddRange(warps[w].ToArray());
            data.Add(numPeople);
            for (int p = 0; p < MAX_PEOPLE; p++)
                data.AddRange(people[p].ToArray());
            data.Add(enemyId);
            data.Add(areaId);

            return data.ToArray();
        }

        public byte GetTile(int x, int y)
        {
            return tiles[x, y];
        }

        public void SetTile(int x, int y, byte t)
        {
            tiles[x, y] = t;
        }

        public Warp GetWarp(int i)
        {
            return warps[i];
        }

        public Warp GetWarp(int x, int y)
        {
            byte offset = (byte)((y * MAP_WIDTH) + x);
            for (int i = 0; i < MAX_WARPS; i++)
                if (warps[i].Offset == offset)
                    return warps[i];
            return null;
        }

        public bool CheckForWarp(int x, int y)
        {
            byte offset = (byte)((y * MAP_WIDTH) + x);
            for (int i = 0; i < MAX_WARPS; i++)
                if (warps[i].Offset == offset)
                    return true;
            return false;
        }

        public void AddWarp(Warp warp)
        {
            warps[numWarps].CopyFrom(warp);
            numWarps++;
        }

        public void RemoveWarp(int x, int y)
        {
            // find the warp
            byte offset = (byte)((y * MAP_WIDTH) + x);
            int warpId;
            for (warpId = 0; warpId < MAX_WARPS; warpId++)
                if (warps[warpId].Offset == offset)
                    break;
            // if found, overwrite down the chain and clear the last warp
            if (warpId < MAX_WARPS)
            {
                numWarps--;
                for (int i = warpId; i < (MAX_WARPS - 1); i++)
                {
                    warps[i].CopyFrom(warps[i + 1]);
                }
                warps[MAX_WARPS - 1].Clear();
            }
        }

        public Person GetPerson(int i)
        {
            return people[i];
        }

        public Person GetPerson(int x, int y)
        {
            byte offset = (byte)((y * MAP_WIDTH) + x);
            for (int i = 0; i < MAX_PEOPLE; i++)
                if (people[i].Offset == offset)
                    return people[i];
            return null;
        }

        public bool CheckForPerson(int x, int y)
        {
            byte offset = (byte)((y * MAP_WIDTH) + x);
            for (int i = 0; i < MAX_PEOPLE; i++)
                if (people[i].Offset == offset)
                    return true;
            return false;
        }

        public void AddPerson(Person person)
        {
            people[numPeople].CopyFrom(person);
            numPeople++;
        }

        public void RemovePerson(int x, int y)
        {
            // find the person
            byte offset = (byte)((y * MAP_WIDTH) + x);
            int personId;
            for (personId = 0; personId < MAX_PEOPLE; personId++)
                if (people[personId].Offset == offset)
                    break;
            // if found, overwrite down the chain and clear the last warp
            if (personId < MAX_PEOPLE)
            {
                numPeople--;
                for (int i = personId; i < (MAX_PEOPLE - 1); i++)
                {
                    people[i].CopyFrom(people[i + 1]);
                }
                people[MAX_PEOPLE - 1].Clear();
            }
        }

        public void InsertRow(int row)
        {
            for (int y = (MAP_HEIGHT - 1); y > row; y--)
                for (int x = 0; x < MAP_WIDTH; x++)
                    tiles[x, y] = tiles[x, y - 1];
        }

        public void InsertColumn(int column)
        {
            for (int x = (MAP_WIDTH - 1); x > column; x--)
                for (int y = 0; y < MAP_HEIGHT; y++)
                    tiles[x, y] = tiles[x - 1, y];
        }

        public static void WriteCsvHeader(TextWriter textWriter)
        {
            textWriter.Write("MAP,UP,DOWN,LEFT,RIGHT,");
            textWriter.Write("NUM_WARPS,");
            textWriter.Write("WARP_1_OFFSET,WARP_1_MAP,WARP_1_X,WARP_1_Y,");
            textWriter.Write("WARP_2_OFFSET,WARP_2_MAP,WARP_2_X,WARP_2_Y,");
            textWriter.Write("WARP_3_OFFSET,WARP_3_MAP,WARP_3_X,WARP_3_Y,");
            textWriter.Write("WARP_4_OFFSET,WARP_4_MAP,WARP_4_X,WARP_4_Y,");
            textWriter.Write("NUM_PEOPLE,");
            textWriter.Write("PERSON_1_OFFSET,PERSON_1_TALKID,");
            textWriter.Write("PERSON_2_OFFSET,PERSON_2_TALKID,");
            textWriter.Write("PERSON_3_OFFSET,PERSON_3_TALKID,");
            textWriter.Write("PERSON_4_OFFSET,PERSON_4_TALKID,");
            textWriter.WriteLine("ENEMY,AREA");
        }

        public void WriteCsv(TextWriter textWriter, int mapNum)
        {
            textWriter.Write(mapNum + ",");
            textWriter.Write(mapUp + ",");
            textWriter.Write(mapDown + ",");
            textWriter.Write(mapLeft + ",");
            textWriter.Write(mapRight + ",");
            textWriter.Write(numWarps + ",");
            for (int w = 0; w < MAX_WARPS; w++)
                warps[w].WriteCsv(textWriter);
            textWriter.Write(numPeople + ",");
            for (int p = 0; p < MAX_PEOPLE; p++)
                people[p].WriteCsv(textWriter);
            textWriter.WriteLine(enemyId + "," + areaId);
        }

        public void ImportMetaData(List<byte> data)
        {
            mapUp = data[1];
            mapDown = data[2];
            mapLeft = data[3];
            mapRight = data[4];
            numWarps = data[5];
            for (int w = 0; w < MAX_WARPS; w++)
            {
                warps[w].Offset = data[6 + (w * 4)];
                warps[w].Map = data[7 + (w * 4)];
                warps[w].X = data[8 + (w * 4)];
                warps[w].Y = data[9 + (w * 4)];
            }
            numPeople = data[22];
            for (int p = 0; p < MAX_PEOPLE; p++)
            {
                people[p].Offset = data[23 + (p * 2)];
                people[p].TalkId = data[24 + (p * 2)];
            }
            enemyId = data[31];
            areaId = data[32];
        }
    }
}
