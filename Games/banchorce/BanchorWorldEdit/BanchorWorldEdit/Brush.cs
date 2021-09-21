using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BanchorWorldEdit
{
    public class Brush
    {
        private byte tileNum;
        private bool smartFlag;
        Random random;

        public byte TileNum => tileNum;

        private const int GROUND_UPPER_ODDS = 10;

        private const byte SAND = 0;
        private const byte GRASS = 1;
        private const byte DIRT = 2;
        private const byte FOREST_1 = 3;
        private const byte FOREST_2 = 4;
        private const byte FOREST_3 = 5;
        private const byte FOREST_4 = 6;
        private const byte DESERT_1 = 7;
        private const byte DESERT_2 = 8;
        private const byte DESERT_3 = 9;
        private const byte DESERT_4 = 10;
        private const byte BEACH_1 = 11;
        private const byte BEACH_2 = 12;
        private const byte BEACH_3 = 13;
        private const byte BEACH_4 = 14;
        private const byte GRASS_1 = 15;
        private const byte GRASS_2 = 16;
        private const byte GRASS_3 = 17;
        private const byte GRASS_4 = 18;
        private const byte SWAMP_1 = 19;
        private const byte SWAMP_2 = 20;
        private const byte SWAMP_3 = 21;
        private const byte SWAMP_4 = 22;
        private const byte SNOW_1 = 23;
        private const byte SNOW_2 = 24;
        private const byte SNOW_3 = 25;
        private const byte SNOW_4 = 26;
        private const byte DIRT_1 = 27;
        private const byte DIRT_2 = 28;
        private const byte DIRT_3 = 29;
        private const byte DIRT_4 = 30;
        private const byte HELL_1 = 31;
        private const byte HELL_2 = 32;
        private const byte HELL_3 = 33;
        private const byte HELL_4 = 34;
        private const byte WEEDS_SMALL = 35;
        private const byte WEEDS_LARGE = 36;
        private const byte FLOWERS_YELLOW = 37;
        private const byte SAND_PEBBLES = 38;
        private const byte DIRT_MOSS = 39;
        private const byte DOOR_UP = 40;
        private const byte DOOR_DOWN = 41;
        private const byte ARCHWAY_UP = 42;
        private const byte ARCHWAY_DOWN = 43;
        private const byte PATH_VILLAGE = 44;
        private const byte PATH_GRAVEYARD = 45;
        private const byte ICE_FLOOR = 46;
        private const byte CARPET_FLOOR = 47;
        private const byte TILED_FLOOR = 48;
        private const byte STONE_FLOOR = 49;
        private const byte BRICK_FLOOR = 50;
        private const byte BRICK_FLOOR_CRACKED = 51;
        private const byte BLUESTONE_FLOOR = 52;
        private const byte BLUESTONE_FLOOR_CRACKED = 53;
        private const byte DARKSTONE_FLOOR = 54;
        private const byte FORTRESS_FLOOR = 55;
        private const byte BRICK_WALL_FAKE = 56;
        private const byte DARKSTONE_WALL_FAKE = 57;
        private const byte FORTRESS_WALL_FAKE = 58;
        private const byte WOOD_BRIDGE_V = 59;
        private const byte WOOD_BRIDGE_H = 60;
        private const byte STONE_BRIDGE_H = 61;
        private const byte STONE_BRIDGE_V = 62;
        private const byte PORTAL_STAIRS = 63;
        private const byte TELEPORT_1 = 64;
        private const byte TELEPORT_2 = 65;
        private const byte TELEPORT_3 = 66;
        private const byte PORTAL_1 = 67;
        private const byte PORTAL_2 = 68;
        private const byte PORTAL_3 = 69;
        private const byte PORTAL_4 = 70;
        private const byte STAIRS_DOWN_L = 71;
        private const byte STAIRS_DOWN_R = 72;
        private const byte STAIRS_UP_L = 73;
        private const byte STAIRS_UP_R = 74;
        private const byte WATER = 75;
        private const byte SWAMPWATER = 76;
        private const byte STONE_SAND = 77;
        private const byte STONE_GRASS = 78;
        private const byte STONE_DIRT = 79;
        private const byte CRUSHED_STONE_SAND = 80;
        private const byte CRUSHED_STONE_GRASS = 81;
        private const byte CRUSHED_STONE_DIRT = 82;
        private const byte ROCK_SAND = 83;
        private const byte ROCK_GRASS = 84;
        private const byte ROCK_DIRT = 85;
        private const byte CRUSHED_ROCK_SAND = 86;
        private const byte CRUSHED_ROCK_GRASS = 87;
        private const byte CRUSHED_ROCK_DIRT = 88;
        private const byte TREES_SAND_1 = 89;
        private const byte TREES_SAND_2 = 90;
        private const byte TREES_SAND_T = 91;
        private const byte TREES_SAND_B = 92;
        private const byte TREES_SAND_L = 93;
        private const byte TREES_SAND_R = 94;
        private const byte TREES_SAND_TL = 95;
        private const byte TREES_SAND_TR = 96;
        private const byte TREES_SAND_BL = 97;
        private const byte TREES_SAND_BR = 98;
        private const byte TREES_GRASS_1 = 99;
        private const byte TREES_GRASS_2 = 100;
        private const byte TREES_GRASS_T = 101;
        private const byte TREES_GRASS_B = 102;
        private const byte TREES_GRASS_L = 103;
        private const byte TREES_GRASS_R = 104;
        private const byte TREES_GRASS_TL = 105;
        private const byte TREES_GRASS_TR = 106;
        private const byte TREES_GRASS_BL = 107;
        private const byte TREES_GRASS_BR = 108;
        private const byte PINETREES_1 = 109;
        private const byte PINETREES_2 = 110;
        private const byte PINETREES_T = 111;
        private const byte PINETREES_B = 112;
        private const byte PINETREES_L = 113;
        private const byte PINETREES_R = 114;
        private const byte PINETREES_TL = 115;
        private const byte PINETREES_TR = 116;
        private const byte PINETREES_BL = 117;
        private const byte PINETREES_BR = 118;
        private const byte PINETREES_WATER_TL = 119;
        private const byte PINETREES_WATER_T = 120;
        private const byte PINETREES_WATER_TR = 121;
        private const byte PINETREE_T = 122;
        private const byte PINETREE_B = 123;
        private const byte SWAMPTREE_1_T = 124;
        private const byte SWAMPTREE_1_B = 125;
        private const byte SWAMPTREE_2_T = 126;
        private const byte SIGN_SAND = 127;
        private const byte SIGN_GRASS = 128;
        private const byte SIGN_DIRT = 129;
        private const byte FENCE = 130;
        private const byte SMALL_TREE = 131;
        private const byte SMALL_BUSH = 132;
        private const byte SMALL_PALMTREE = 133;
        private const byte PALMTREE_T = 134;
        private const byte PALMTREE_B = 135;
        private const byte DEAD_TREE_TL = 136;
        private const byte DEAD_TREE_TR = 137;
        private const byte DEAD_TREE_BL = 138;
        private const byte DEAD_TREE_BR = 139;
        private const byte ROCK_WATER = 140;
        private const byte CACTUS_1_T = 141;
        private const byte CACTUS_1_B = 142;
        private const byte CACTUS_2_T = 143;
        private const byte CACTUS_2_B = 144;
        private const byte CACTUS_3_T = 145;
        private const byte CACTUS_3_B = 146;
        private const byte BONES_DESERT = 147;
        private const byte BONES_DIRT = 148;
        private const byte CROSS = 149;
        private const byte TOMB = 150;
        private const byte THICKET_1 = 151;
        private const byte THICKET_2 = 152;
        private const byte THICKET_T = 153;
        private const byte THICKET_B = 154;
        private const byte THICKET_L = 155;
        private const byte THICKET_R = 156;
        private const byte THICKET_TL = 157;
        private const byte THICKET_TR = 158;
        private const byte THICKET_BL = 159;
        private const byte THICKET_BR = 160;
        private const byte LIFEWELL_1 = 161;
        private const byte LIFEWELL_2 = 162;
        private const byte CHEST_CLOSED = 163;
        private const byte CHEST_OPEN = 164;
        private const byte LAVA = 165;
        private const byte WATERFALL_1 = 166;
        private const byte WATERFALL_2 = 167;
        private const byte WATERFALL_3 = 168;
        private const byte WATERFALL_4 = 169;
        private const byte WATERFALL_SPLASH_1 = 170;
        private const byte WATERFALL_SPLASH_2 = 171;
        private const byte CAVE_WALL = 172;
        private const byte CAVE_WALL_T = 173;
        private const byte CAVE_WALL_B = 174;
        private const byte CAVE_WALL_L = 175;
        private const byte CAVE_WALL_R = 176;
        private const byte CAVE_WALL_TL = 177;
        private const byte CAVE_WALL_TR = 178;
        private const byte CAVE_WALL_BL = 179;
        private const byte CAVE_WALL_BR = 180;
        private const byte WOOD_WALL = 181;
        private const byte HOUSE_WINDOW = 182;
        private const byte HOUSE_ROOF_TL = 183;
        private const byte HOUSE_ROOF_TC = 184;
        private const byte HOUSE_ROOF_TR = 185;
        private const byte HOUSE_ROOF_BL = 186;
        private const byte HOUSE_ROOF_BC = 187;
        private const byte HOUSE_ROOF_BR = 188;
        private const byte PYRAMID_TL = 189;
        private const byte PYRAMID_TC = 190;
        private const byte PYRAMID_TR = 191;
        private const byte PYRAMID_BL = 192;
        private const byte PYRAMID_BR = 193;
        private const byte CASTLE_OUTER_TOWER = 194;
        private const byte CASTLE_INNER_TOWER = 195;
        private const byte CASTLE_OUTER_WALL_L = 196;
        private const byte CASTLE_OUTER_WALL_R = 197;
        private const byte PALACE_OUTER_TOWER = 198;
        private const byte PALACE_INNER_TOWER = 199;
        private const byte PALACE_OUTER_WALL = 200;
        private const byte TEMPLE_OUTER_TOWER = 201;
        private const byte TEMPLE_INNER_TOWER = 202;
        private const byte TEMPLE_OUTER_WALL = 203;
        private const byte FORTRESS_OUTER_TOWER = 204;
        private const byte FORTRESS_INNER_TOWER = 205;
        private const byte FORTRESS_OUTER_WALL = 206;
        private const byte BONES_TOMB = 207;
        private const byte BONES_FORTRESS = 208;
        private const byte BED_T = 209;
        private const byte BED_B = 210;
        private const byte BARREL = 211;
        private const byte STONE_WALL_1 = 212;
        private const byte STONE_WALL_2 = 213;
        private const byte MOSSY_STONE_WALL = 214;
        private const byte BRICK_WALL_1 = 215;
        private const byte BRICK_WALL_2 = 216;
        private const byte ICE_WALL_1 = 217;
        private const byte ICE_WALL_2 = 218;
        private const byte MOSSY_ROCK_WALL_1 = 219;
        private const byte MOSSY_ROCK_WALL_2 = 220;
        private const byte BLUESTONE_WALL_1 = 221;
        private const byte BLUESTONE_WALL_2 = 222;
        private const byte DARKSTONE_WALL_1 = 223;
        private const byte DARKSTONE_WALL_2 = 224;
        private const byte FORTRESS_WALL_1 = 225;
        private const byte FORTRESS_WALL_2 = 226;
        private const byte CHAIR_L = 227;
        private const byte CHAIR_R = 228;
        private const byte TABLE = 229;
        private const byte PORTAL_BASE = 230;
        private const byte PORTAL_EMPTY = 231;
        private const byte ROCK_WALL_1 = 232;
        private const byte ROCK_WALL_2 = 233;
        private const byte ROCK_WALL_3 = 234;
        private const byte ROCK_WALL_4 = 235;
        private const byte CLOSED_DOOR_UP = 236;
        private const byte CLOSED_DOOR_DOWN = 237;
        private const byte WATER_BLOCKADE = 238;
        private const byte PRISON_DOOR = 239;
        private const byte PERSON_STONE_L = 240;
        private const byte PERSON_STONE_R = 241;
        private const byte PERSON_SAND_L = 242;
        private const byte PERSON_SAND_R = 243;
        private const byte PERSON_GRASS_L = 244;
        private const byte PERSON_GRASS_R = 245;
        private const byte PERSON_DIRT_L = 246;
        private const byte PERSON_DIRT_R = 247;
        private const byte SAPPHIRA_STONE_U = 248;
        private const byte SAPPHIRA_STONE_D = 249;
        private const byte SAPPHIRA_SAND_U = 250;
        private const byte SAPPHIRA_SAND_D = 251;
        private const byte SAPPHIRA_GRASS_U = 252;
        private const byte SAPPHIRA_GRASS_D = 253;
        private const byte SAPPHIRA_DIRT_U = 254;
        private const byte SAPPHIRA_DIRT_D = 255;

        public Brush(byte tileNum, bool smartFlag)
        {
            this.tileNum = tileNum;
            this.smartFlag = smartFlag;
            random = new Random();
        }

        public byte BrushTile()
        {
            if (!smartFlag)
                return tileNum;

            return smartTile();
        }

        private byte smartTile()
        {
            switch (tileNum)
            {
                case FOREST_1:
                case FOREST_2:
                case FOREST_3:
                case FOREST_4:
                    return forestTile();
                case DESERT_1:
                case DESERT_2:
                case DESERT_3:
                case DESERT_4:
                    return desertTile();
                case BEACH_1:
                case BEACH_2:
                case BEACH_3:
                case BEACH_4:
                    return beachTile();
                case GRASS_1:
                case GRASS_2:
                case GRASS_3:
                case GRASS_4:
                    return grassTile();
                case SWAMP_1:
                case SWAMP_2:
                case SWAMP_3:
                case SWAMP_4:
                    return swampTile();
                case SNOW_1:
                case SNOW_2:
                case SNOW_3:
                case SNOW_4:
                    return snowTile();
                case DIRT_1:
                case DIRT_2:
                case DIRT_3:
                case DIRT_4:
                    return dirtTile();
                case HELL_1:
                case HELL_2:
                case HELL_3:
                case HELL_4:
                    return hellTile();
                case STONE_WALL_1:
                case STONE_WALL_2:
                    return stoneWallTile();
                case MOSSY_STONE_WALL:
                    return mossyStoneWallTile();
                case BRICK_WALL_1:
                case BRICK_WALL_2:
                    return brickWallTile();
                case ICE_WALL_1:
                case ICE_WALL_2:
                    return iceWallTile();
                case MOSSY_ROCK_WALL_1:
                case MOSSY_ROCK_WALL_2:
                    return mossyRockWallTile();
                case BLUESTONE_WALL_1:
                case BLUESTONE_WALL_2:
                    return blueStoneWallTile();
                case DARKSTONE_WALL_1:
                case DARKSTONE_WALL_2:
                    return darkStoneWallTile();
                case FORTRESS_WALL_1:
                case FORTRESS_WALL_2:
                    return fortressWallTile();
                case ROCK_WALL_1:
                case ROCK_WALL_2:
                case ROCK_WALL_3:
                case ROCK_WALL_4:
                    return rockWallTile();
                default:
                    return tileNum;
            }
        }

        private byte forestTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return SAND;
            else
            {
                t = random.Next(0, 4);
                return (byte)(FOREST_1 + t);
            }
        }

        private byte desertTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return SAND;
            else
            {
                t = random.Next(0, 4);
                return (byte)(DESERT_1 + t);
            }
        }

        private byte beachTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return SAND;
            else
            {
                t = random.Next(0, 4);
                return (byte)(BEACH_1 + t);
            }
        }

        private byte grassTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return GRASS;
            else
            {
                t = random.Next(0, 4);
                return (byte)(GRASS_1 + t);
            }
        }

        private byte swampTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return GRASS;
            else
            {
                t = random.Next(0, 4);
                return (byte)(SWAMP_1 + t);
            }
        }

        private byte snowTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return GRASS;
            else
            {
                t = random.Next(0, 4);
                return (byte)(SNOW_1 + t);
            }
        }

        private byte dirtTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return DIRT;
            else
            {
                t = random.Next(0, 4);
                return (byte)(DIRT_1 + t);
            }
        }

        private byte hellTile()
        {
            int t = random.Next(0, GROUND_UPPER_ODDS);
            if (t == 0)
                return DIRT;
            else
            {
                t = random.Next(0, 4);
                return (byte)(HELL_1 + t);
            }
        }

        private byte stoneWallTile()
        {
            int t = random.Next(0, 3);
            if (t != 1) t = 0;
            return (byte)(STONE_WALL_1 + t);
        }

        private byte mossyStoneWallTile()
        {
            int t = random.Next(0, 4);
            if (t > 2) t = 2;
            return (byte)(STONE_WALL_1 + t);
        }

        private byte brickWallTile()
        {
            int t = random.Next(0, 5);
            if (t != 1) t = 0;
            return (byte)(BRICK_WALL_1 + t);
        }

        private byte iceWallTile()
        {
            int t = random.Next(0, 2);
            return (byte)(ICE_WALL_1 + t);
        }

        private byte mossyRockWallTile()
        {
            int t = random.Next(0, 6);
            if (t <= 1)
            {
                return (byte)(MOSSY_ROCK_WALL_1 + t);
            }
            else
            {
                t -= 2;
                return (byte)(ROCK_WALL_1 + t);
            }
        }

        private byte blueStoneWallTile()
        {
            int t = random.Next(0, 3);
            if (t != 1) t = 0;
            return (byte)(BLUESTONE_WALL_1 + t);
        }

        private byte darkStoneWallTile()
        {
            int t = random.Next(0, 3);
            if (t != 1) t = 0;
            return (byte)(DARKSTONE_WALL_1 + t);
        }

        private byte fortressWallTile()
        {
            int t = random.Next(0, 3);
            if (t != 1) t = 0;
            return (byte)(FORTRESS_WALL_1 + t);
        }

        private byte rockWallTile()
        {
            int t = random.Next(0, 4);
            return (byte)(ROCK_WALL_1 + t);
        }
    }
}
