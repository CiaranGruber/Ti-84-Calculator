using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BanchorWorldEdit
{
    public partial class FormMain : Form
    {
        private World world;

        private byte mapNum = 0;
        private Map map;
        private Warp warpDest;
        private Point editPos = new Point(-1, -1);
        private Brush brush;
        private bool brushFlag = false;
        private bool changeFlag = false;

        public FormMain()
        {
            InitializeComponent();

            picTileset.BackgroundImage = Image.FromFile("tileset.png");

            brush = new Brush(0, checkSmartBrush.Checked);
            numericJump.Maximum = World.MAX_MAPS - 1;
            newWorld();
        }

        private void FormMain_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (changeFlag)
                if (checkSaveChanges("exiting") == DialogResult.Cancel)
                    e.Cancel = true;
        }

        /*
         * navigation buttons
         */
        private void buttonUp_Click(object sender, EventArgs e)
        {
            if (map.MapUp != 255)
            {
                warpDest = null;
                mapNum = map.MapUp;
                updateFields();
            }
        }

        private void buttonDown_Click(object sender, EventArgs e)
        {
            if (map.MapDown != 255)
            {
                warpDest = null;
                mapNum = map.MapDown;
                updateFields();
            }
        }

        private void buttonLeft_Click(object sender, EventArgs e)
        {
            if (map.MapLeft != 255)
            {
                warpDest = null;
                mapNum = map.MapLeft;
                updateFields();
            }
        }

        private void buttonRight_Click(object sender, EventArgs e)
        {
            if (map.MapRight != 255)
            {
                warpDest = null;
                mapNum = map.MapRight;
                updateFields();
            }
        }

        private void buttonJump_Click(object sender, EventArgs e)
        {
            byte jumpNum = (byte)numericJump.Value;
            if (jumpNum < world.NumMaps)
            {
                warpDest = null;
                mapNum = jumpNum;
                updateFields();
            }
        }

        private void numericJump_KeyPress(object sender, KeyPressEventArgs e)
        {
            byte jumpNum = (byte)numericJump.Value;
            if (e.KeyChar == (char)13 && jumpNum < world.NumMaps)
            {
                warpDest = null;
                mapNum = (byte)numericJump.Value;
                updateFields();
            }
        }

        /*
         * comboBoxArea
         */
        private void comboBoxArea_SelectionChangeCommitted(object sender, EventArgs e)
        {
            changeFlag = true;
            map.AreaId = (byte)comboBoxArea.SelectedIndex;
        }

        /*
         * buttonFill
         */
        private void buttonFill_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Fill current map with selected brush?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                changeFlag = true;
                for (int y = 0; y < Map.MAP_HEIGHT; y++)
                    for (int x = 0; x < Map.MAP_WIDTH; x++)
                        map.SetTile(x, y, brush.BrushTile());
                picMap.Refresh();
            }
        }

        /*
         * numeric map field
         */
        private void numericMapUp_ValueChanged(object sender, EventArgs e)
        {
            changeFlag = true;
            map.MapUp = (byte)numericMapUp.Value;
            updateFields();
        }

        private void numericMapDown_ValueChanged(object sender, EventArgs e)
        {
            changeFlag = true;
            map.MapDown = (byte)numericMapDown.Value;
            updateFields();
        }

        private void numericMapLeft_ValueChanged(object sender, EventArgs e)
        {
            changeFlag = true;
            map.MapLeft = (byte)numericMapLeft.Value;
            updateFields();
        }

        private void numericMapRight_ValueChanged(object sender, EventArgs e)
        {
            changeFlag = true;
            map.MapRight = (byte)numericMapRight.Value;
            updateFields();
        }

        /*
         * picMap
         */
        private void picMap_MouseClick(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Middle)
            {
                brush = new Brush(map.GetTile(editPos.X, editPos.Y), checkSmartBrush.Checked);
                picMap.Refresh();
                picTileset.Refresh();
            }
        }

        private void picMap_MouseDown(object sender, MouseEventArgs e)
        {
            if (e.Button == MouseButtons.Left && editPos.X == e.X / 32 && editPos.Y == e.Y / 32)
            {
                changeFlag = true;
                brushFlag = true;
                map.SetTile(editPos.X, editPos.Y, brush.BrushTile());
                picMap.Refresh();
            }
        }

        private void picMap_MouseLeave(object sender, EventArgs e)
        {
            updateStatusStrip();
            picMap.Refresh();
        }

        private void picMap_MouseMove(object sender, MouseEventArgs e)
        {
            editPos.X = e.X / 32;
            editPos.Y = e.Y / 32;
            updateStatusStrip();
            if (brushFlag)
            {
                if (editPos.X >= 0 && editPos.X < Map.MAP_WIDTH && editPos.Y >=0 && editPos.Y < Map.MAP_HEIGHT)
                {
                    changeFlag = true;
                    map.SetTile(editPos.X, editPos.Y, brush.BrushTile());
                }
            }
            picMap.Refresh();
        }

        private void picMap_MouseUp(object sender, MouseEventArgs e)
        {
            brushFlag = false;
        }

        private void picMap_Paint(object sender, PaintEventArgs e)
        {
            // fill background
            e.Graphics.FillRectangle(Brushes.LightGray, new Rectangle(0, 0, picMap.Width, picMap.Height));

            // draw map
            Bitmap tileset = new Bitmap(picTileset.BackgroundImage);
            for (int y = 0; y < Map.MAP_HEIGHT; y++)
            {
                for (int x = 0; x < Map.MAP_WIDTH; x++)
                {
                    // draw standard edit view
                    int tileNum = (int)map.GetTile(x, y);
                    int tileX = tileNum % 16;
                    int tileY = tileNum / 16;
                    Bitmap tileImage = tileset.Clone(new Rectangle(tileX * 32, tileY * 32, 32, 32), tileset.PixelFormat);
                    e.Graphics.DrawImage(tileImage, x * 32, y * 32);
                }
            }

            // draw brush
            if (editPos.X != -1 && editPos.Y != -1)
            {
                int x = editPos.X;
                int y = editPos.Y;
                Bitmap tileImage = tileset.Clone(new Rectangle(brush.TileNum % 16 * 32, brush.TileNum / 16 * 32, 32, 32), tileset.PixelFormat);
                for (int bx = 0; bx < 32; bx++)
                {
                    for (int by = 0; by < 32; by++)
                    {
                        Color c = tileImage.GetPixel(bx, by);
                        tileImage.SetPixel(bx, by, Color.FromArgb(192, c));
                    }
                }
                e.Graphics.DrawImage(tileImage, x * 32, y * 32);
            }

            // draw warps
            for (int i = 0; i < map.NumWarps; i++)
            {
                Warp warp = map.GetWarp(i);
                int x = warp.Offset % Map.MAP_WIDTH;
                int y = warp.Offset / Map.MAP_WIDTH;
                e.Graphics.DrawRectangle(new Pen(Color.LimeGreen, 2), (x * 32) + 1, (y * 32) + 1, 30, 30);
            }

            if (warpDest != null)
            {
                int x = warpDest.Offset % Map.MAP_WIDTH;
                int y = warpDest.Offset / Map.MAP_WIDTH;
                e.Graphics.DrawRectangle(new Pen(Color.DarkViolet, 2), (x * 32) + 1, (y * 32) + 1, 30, 30);
            }

            // draw people
            for (int i = 0; i < map.NumPeople; i++)
            {
                Person person = map.GetPerson(i);
                int x = person.Offset % Map.MAP_WIDTH;
                int y = person.Offset / Map.MAP_WIDTH;
                e.Graphics.DrawRectangle(new Pen(Color.DarkCyan, 2), (x * 32) + 1, (y * 32) + 1, 30, 30);
            }

            // draw chests
            for (int i = 0; i < World.MAX_CHESTS; i++)
            {
                Chest chest = world.GetChest(i);
                if (chest.Map == mapNum)
                {
                    int x = chest.Offset % Map.MAP_WIDTH;
                    int y = chest.Offset / Map.MAP_WIDTH;
                    e.Graphics.DrawRectangle(new Pen(Color.Magenta, 2), (x * 32) + 1, (y * 32) + 1, 30, 30);
                }
            }
        }

        /*
         * picTileset
         */
        private void picTileset_MouseClick(object sender, MouseEventArgs e)
        {
            brush = new Brush((byte)((e.Y / 32 * 16) + (e.X / 32)), checkSmartBrush.Checked);
            updateStatusStrip();
            picTileset.Refresh();
        }

        private void picTileset_Paint(object sender, PaintEventArgs e)
        {
            Rectangle rect = new Rectangle((brush.TileNum % 16) * 32, (brush.TileNum / 16) * 32, 32, 32);
            e.Graphics.FillRectangle(new SolidBrush(Color.FromArgb(128, 255, 192, 255)), rect);
        }

        /*
         * picEnemy
         */
        private void picEnemy_Paint(object sender, PaintEventArgs e)
        {
            Bitmap enemies = new Bitmap(picEnemies.BackgroundImage);
            Bitmap enemyImage = enemies.Clone(new Rectangle((map.EnemyId % 16) * 32, (map.EnemyId / 16) * 32, 32, 32), enemies.PixelFormat);
            e.Graphics.DrawImage(enemyImage, 0, 0);
        }

        /*
         * picEnemies
         */
        private void picEnemies_MouseClick(object sender, MouseEventArgs e)
        {
            byte enemyId = (byte)((e.Y / 32 * 16) + (e.X / 32));
            if (enemyId <= World.MAX_ENEMY_ID)
            {
                changeFlag = true;
                map.EnemyId = enemyId;
                picEnemy.Refresh();
            }
        }

        /*
         * checkSmartBrush
         */
        private void checkSmartBrush_CheckedChanged(object sender, EventArgs e)
        {
            brush = new Brush(brush.TileNum, checkSmartBrush.Checked);
        }

        /*
         * newToolStripMenuItem
         */
        private void newToolStripMenuItem_Click(object sender, EventArgs e)
        {
            newWorld();
        }

        /*
         * openToolStripMenuItem
         */
        private void openToolStripMenuItem_Click(object sender, EventArgs e)
        {
            openWorld();
        }

        /*
         * saveToolStripMenuItem
         */
        private void saveToolStripMenuItem_Click(object sender, EventArgs e)
        {
            saveWorld();
        }

        /*
         * exitToolStripMenuItem
         */
        private void exitToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Application.Exit();
        }

        /*
         * addMapToolStripMenuItem
         */
        private void addMapToolStripMenuItem_Click(object sender, EventArgs e)
        {
            world.AddMap();
        }

        /*
         * insertMapToolStripMenuItem
         */
        private void insertMapToolStripMenuItem_Click(object sender, EventArgs e)
        {
            world.InsertMap(mapNum);
            updateFields();
        }

        /*
         * deleteMapToolStripMenuItem
         */
        private void deleteMapToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("Delete this map?", "", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                world.DeleteMap(mapNum);
                updateFields();
            }
        }

        /*
         * mapPNGToolStripMenuItem
         */
        private void mapPNGToolStripMenuItem_Click(object sender, EventArgs e)
        {
            exportPng();
        }

        /*
         * dataCSVsToolStripMenuItem
         */
        private void dataCSVsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            exportCsv();
        }

        /*
         * chestCSVToolStripMenuItem
         */
        private void chestCSVToolStripMenuItem_Click(object sender, EventArgs e)
        {
            importChestData();
        }

        /*
         * tileCSVToolStripMenuItem
         */
        private void tileCSVToolStripMenuItem_Click(object sender, EventArgs e)
        {
            importTileIDs();
        }

        /*
         * mapIDsToolStripMenuItem
         */
        private void mapIDsToolStripMenuItem_Click(object sender, EventArgs e)
        {
            importMapIDs();
        }

        /*
         * mapMetaDataToolStripMenuItem
         */
        private void mapMetaDataToolStripMenuItem_Click(object sender, EventArgs e)
        {
            importMapMetaData();
        }

        /*
         * newToolStripButton
         */
        private void newToolStripButton_Click(object sender, EventArgs e)
        {
            newWorld();
        }

        /*
         * openToolStripButton
         */
        private void openToolStripButton_Click(object sender, EventArgs e)
        {
            openWorld();
        }

        /*
         * saveToolStripButton
         */
        private void saveToolStripButton_Click(object sender, EventArgs e)
        {
            saveWorld();
        }

        /*
         * toolStripExportPng
         */
        private void toolStripExportPng_Click(object sender, EventArgs e)
        {
            exportPng();
        }

        /*
         * toolStripExportXls
         */
        private void toolStripExportXls_Click(object sender, EventArgs e)
        {
            exportCsv();
        }

        /*
         * contextMenuMap
         */
        private void contextMenuMap_Closed(object sender, ToolStripDropDownClosedEventArgs e)
        {
            // show all options
            for (int i = 0; i < contextMenuMap.Items.Count; i++)
                contextMenuMap.Items[i].Visible = true;
        }

        private void contextMenuMap_Opening(object sender, CancelEventArgs e)
        {
            // hide all options
            for (int i = 0; i < contextMenuMap.Items.Count; i++)
                contextMenuMap.Items[i].Visible = false;

            // check for warp
            if (map.CheckForWarp(editPos.X, editPos.Y))
            {
                contextMenuMapWarp();
                return;
            }

            // check for person
            if (map.CheckForPerson(editPos.X, editPos.Y))
            {
                contextMenuMapPerson();
                return;
            }

            // check for chest
            if (world.CheckForChest(mapNum, editPos.X, editPos.Y))
            {
                contextMenuMapChest();
                return;
            }

            // otherwise, general menu
            addWarpToolStripMenuItem.Visible = true;
            addPersonToolStripMenuItem.Visible = true;
            addChestToolStripMenuItem.Visible = true;
            insertRowToolStripMenuItem.Visible = true;
            insertColumnToolStripMenuItem.Visible = true;
        }

        private void contextMenuMapWarp()
        {
            followWarpToolStripMenuItem.Visible = true;
            editWarpToolStripMenuItem.Visible = true;
            removeWarpToolStripMenuItem.Visible = true;
        }

        private void contextMenuMapPerson()
        {
            editPersonToolStripMenuItem.Visible = true;
            removePersonToolStripMenuItem.Visible = true;
        }

        private void contextMenuMapChest()
        {
            editChestToolStripMenuItem.Visible = true;
            removeChestToolStripMenuItem.Visible = true;
        }

        private void addWarpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (map.NumWarps < Map.MAX_WARPS)
            {
                Warp warp = new Warp();
                warp.Offset = Map.CalcOffset(editPos.X, editPos.Y);
                FormWarp formWarp = new FormWarp(warp);
                if (formWarp.ShowDialog() == DialogResult.OK)
                {
                    changeFlag = true;
                    warp.Offset = formWarp.Offset;
                    warp.Map = formWarp.MapNum;
                    warp.X = formWarp.X;
                    warp.Y = formWarp.Y;
                    map.AddWarp(warp);
                    picMap.Refresh();
                }
            }
            else
            {
                MessageBox.Show("Maximum number of warps reached on this screen!", "", MessageBoxButtons.OK);
            }
        }

        private void followWarpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Warp warp = map.GetWarp(editPos.X, editPos.Y);
            mapNum = warp.Map;
            if (mapNum != 255)
            {
                warpDest = new Warp();
                warpDest.Offset = (byte)(((warp.Y / 8) * Map.MAP_WIDTH) + (warp.X / 8));
                updateFields();
            }
            else
                MessageBox.Show("Warp to Boss #" + (warp.X / 8), "", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void editWarpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Warp warp = map.GetWarp(editPos.X, editPos.Y);
            FormWarp formWarp = new FormWarp(warp);
            if (formWarp.ShowDialog() == DialogResult.OK)
            {
                changeFlag = true;
                warp.Offset = formWarp.Offset;
                warp.Map = formWarp.MapNum;
                warp.X = formWarp.X;
                warp.Y = formWarp.Y;
                picMap.Refresh();
            }
        }

        private void removeWarpToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult dialogResult = MessageBox.Show("Remove warp?", "", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {
                changeFlag = true;
                map.RemoveWarp(editPos.X, editPos.Y);
                picMap.Refresh();
            }
        }

        private void addPersonToolStripMenuItem_Click(object sender, EventArgs e)
        {
            if (map.NumPeople < Map.MAX_PEOPLE)
            {
                Person person = new Person();
                person.Offset = Map.CalcOffset(editPos.X, editPos.Y);
                FormPerson formPerson = new FormPerson(person);
                if (formPerson.ShowDialog() == DialogResult.OK)
                {
                    changeFlag = true;
                    person.Offset = formPerson.Offset;
                    person.TalkId = formPerson.TalkId;
                    map.AddPerson(person);
                    picMap.Refresh();
                }
            }
            else
            {
                MessageBox.Show("Maximum number of people reached on this screen!", "", MessageBoxButtons.OK);
            }
        }

        private void editPersonToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Person person = map.GetPerson(editPos.X, editPos.Y);
            FormPerson formPerson = new FormPerson(person);
            if (formPerson.ShowDialog() == DialogResult.OK)
            {
                changeFlag = true;
                person.Offset = formPerson.Offset;
                person.TalkId = formPerson.TalkId;
                picMap.Refresh();
            }
        }

        private void removePersonToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult dialogResult = MessageBox.Show("Remove person?", "", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {
                changeFlag = true;
                map.RemovePerson(editPos.X, editPos.Y);
                picMap.Refresh();
            }
        }

        private void addChestToolStripMenuItem_Click(object sender, EventArgs e)
        {
            int c = world.FindEmptyChestSlot();
            if (c < World.MAX_CHESTS)
            {
                Chest chest = world.GetChest(c);
                chest.Map = mapNum;
                chest.Offset = Map.CalcOffset(editPos.X, editPos.Y);
                FormChest formChest = new FormChest(chest);
                if (formChest.ShowDialog() == DialogResult.OK)
                {
                    changeFlag = true;
                    chest.Offset = formChest.Offset;
                    chest.ItemId = formChest.ItemId;
                    picMap.Refresh();
                }
            }
            else
            {
                MessageBox.Show("Maximum number of chests reached in this world!", "", MessageBoxButtons.OK);
            }
        }

        private void editChestToolStripMenuItem_Click(object sender, EventArgs e)
        {
            Chest chest = world.GetChest(mapNum, editPos.X, editPos.Y);
            FormChest formChest = new FormChest(chest);
            if (formChest.ShowDialog() == DialogResult.OK)
            {
                changeFlag = true;
                chest.Offset = formChest.Offset;
                chest.ItemId = formChest.ItemId;
                picMap.Refresh();
            }
        }

        private void removeChestToolStripMenuItem_Click(object sender, EventArgs e)
        {
            DialogResult dialogResult = MessageBox.Show("Remove chest?", "", MessageBoxButtons.YesNo);
            if (dialogResult == DialogResult.Yes)
            {
                changeFlag = true;
                world.RemoveChest(mapNum, editPos.X, editPos.Y);
                picMap.Refresh();
            }
        }

        private void insertRowToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // TODO needs to also update warps, people & chests
            // TODO needs to update warps that send the player to this map
            changeFlag = true;
            map.InsertRow(editPos.Y);
            picMap.Refresh();
        }

        private void insertColumnToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // TODO needs to also update warps, people & chests
            // TODO needs to update warps that send the player to this map
            changeFlag = true;
            map.InsertColumn(editPos.X);
            picMap.Refresh();
        }

        /*
         * misc functions
         */
        private void newWorld()
        {
            if (changeFlag)
                if (checkSaveChanges("creating new world") == DialogResult.Cancel)
                    return;
            world = new World();
            mapNum = 0;
            updateFields();
            changeFlag = false;
        }

        private void openWorld()
        {
            if (changeFlag)
                if (checkSaveChanges("opening world") == DialogResult.Cancel)
                    return;

            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "RPG files (*.rpg)|*.rpg";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                world = new World(openFileDialog.FileName.Substring(0, openFileDialog.FileName.Length - 4));
                mapNum = 0;
                updateFields();
                changeFlag = false;
            }
        }

        private DialogResult saveWorld()
        {
            if (world.Validate())
            {
                if (world.FileName != "")
                {
                    world.Save();
                    changeFlag = false;
                    return DialogResult.OK;
                }
                else
                {
                    SaveFileDialog saveFileDialog = new SaveFileDialog();
                    saveFileDialog.Filter = "RPG files (*.rpg)|*.rpg";
                    saveFileDialog.OverwritePrompt = true;

                    if (saveFileDialog.ShowDialog() == DialogResult.OK)
                    {
                        world.Save(saveFileDialog.FileName.Substring(0, saveFileDialog.FileName.Length - 4));
                        changeFlag = false;
                        return DialogResult.OK;
                    }
                    else
                        return DialogResult.Cancel;
                }
            }
            else
            {
                return DialogResult.Cancel;
            }
        }

        private DialogResult checkSaveChanges(string operation)
        {
            DialogResult result = MessageBox.Show("Save changes before " + operation + "?", "", MessageBoxButtons.YesNoCancel);
            if (result == DialogResult.Yes)
                return saveWorld();
            return result;
        }

        private void exportPng()
        {
            if (world.FileName == "")
            {
                MessageBox.Show("World must be saved before exporting", "", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            var gridFlag = false;
            if (MessageBox.Show("Include map grid?", "Export PNG", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                gridFlag = true;
            world.ExportToPng(new Bitmap(picTileset.BackgroundImage), gridFlag);
        }

        private void exportCsv()
        {
            if (world.FileName == "")
            {
                MessageBox.Show("World must be saved before exporting", "", MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                return;
            }

            world.ExportToCsv();
        }

        private void importChestData()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "CSV files (*.csv)|*.csv";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                world.ImportChestData(openFileDialog.FileName);
                updateFields();
                changeFlag = true;
            }
        }

        private void importTileIDs()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "CSV files (*.csv)|*.csv";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                world.ImportTileIDs(openFileDialog.FileName);
                updateFields();
                changeFlag = true;
            }
        }

        private void importMapIDs()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "CSV files (*.csv)|*.csv";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                world.ImportMapIDs(openFileDialog.FileName);
                updateFields();
                changeFlag = true;
            }
        }

        private void importMapMetaData()
        {
            OpenFileDialog openFileDialog = new OpenFileDialog();
            openFileDialog.Filter = "CSV files (*.csv)|*.csv";

            if (openFileDialog.ShowDialog() == DialogResult.OK)
            {
                world.ImportMapMetaData(openFileDialog.FileName);
                updateFields();
                changeFlag = true;
            }
        }

        private void updateFields()
        {
            map = world.GetMap(mapNum);
            int m;

            m = map.MapUp;
            numericMapUp.Value = m;
            if (m != 255) { buttonUp.Enabled = true; buttonUp.BackgroundImageLayout = ImageLayout.Stretch; }
            else { buttonUp.Enabled = false; buttonUp.BackgroundImageLayout = ImageLayout.Center; }

            m = map.MapDown;
            numericMapDown.Value = m;
            if (m != 255) { buttonDown.Enabled = true; buttonDown.BackgroundImageLayout = ImageLayout.Stretch; }
            else { buttonDown.Enabled = false; buttonDown.BackgroundImageLayout = ImageLayout.Center; }

            m = map.MapLeft;
            numericMapLeft.Value = m;
            if (m != 255) { buttonLeft.Enabled = true; buttonLeft.BackgroundImageLayout = ImageLayout.Stretch; }
            else { buttonLeft.Enabled = false; buttonLeft.BackgroundImageLayout = ImageLayout.Center; }

            m = map.MapRight;
            numericMapRight.Value = m;
            if (m != 255) { buttonRight.Enabled = true; buttonRight.BackgroundImageLayout = ImageLayout.Stretch; }
            else { buttonRight.Enabled = false; buttonRight.BackgroundImageLayout = ImageLayout.Center; }

            comboBoxArea.SelectedIndex = map.AreaId;

            picMap.Refresh();
            picEnemy.Refresh();
            updateStatusStrip();
        }

        private void updateStatusStrip()
        {
            statusStripMapNum.Text = "Map #" + mapNum;

            if (editPos.X >= 0 && editPos.X < Map.MAP_WIDTH && editPos.Y >= 0 && editPos.Y < Map.MAP_HEIGHT)
            {
                statusStripMousePos.Text = "(" + editPos.X + ", " + editPos.Y + ")";
                statusStripMouseOffset.Text = "(" + ((editPos.Y * Map.MAP_WIDTH) + editPos.X) + ")";
                statusStripMapTile.Text = "Map Tile: " + map.GetTile(editPos.X, editPos.Y);
            }
            else
            {
                statusStripMousePos.Text = "";
                statusStripMouseOffset.Text = "";
                statusStripMapTile.Text = "";
            }

            statusStripBrushTile.Text = "Brush Tile: " + brush.TileNum;

            statusStripNumMaps.Text = "Total Maps: " + world.NumMaps;

            statusStrip.Update();
        }
    }
}
