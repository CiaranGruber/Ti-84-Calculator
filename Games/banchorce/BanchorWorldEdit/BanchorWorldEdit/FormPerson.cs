using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace BanchorWorldEdit
{
    public partial class FormPerson : Form
    {
        private byte offset;

        public FormPerson(Person person)
        {
            InitializeComponent();

            numericTalkId.Minimum = 0;
            numericTalkId.Maximum = 255;

            offset = person.Offset;
            updatePosition();
            numericTalkId.Value = person.TalkId;
        }

        public byte Offset => offset;
        public byte TalkId => (byte)numericTalkId.Value;

        private void buttonOK_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.OK;
        }

        private void buttonCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
        }

        private void buttonUp_Click(object sender, EventArgs e)
        {
            if (offset >= Map.MAP_WIDTH)
            {
                offset -= Map.MAP_WIDTH;
                updatePosition();
            }
        }

        private void buttonDown_Click(object sender, EventArgs e)
        {
            if ((offset / Map.MAP_WIDTH) < (Map.MAP_HEIGHT - 1))
            {
                offset += Map.MAP_WIDTH;
                updatePosition();
            }
        }

        private void buttonLeft_Click(object sender, EventArgs e)
        {
            if ((offset % Map.MAP_WIDTH) > 0)
            {
                offset--;
                updatePosition();
            }
        }

        private void buttonRight_Click(object sender, EventArgs e)
        {
            if ((offset % Map.MAP_WIDTH) < (Map.MAP_WIDTH - 1))
            {
                offset++;
                updatePosition();
            }
        }

        private void updatePosition()
        {
            textXPos.Text = ((int)(offset % Map.MAP_WIDTH)).ToString();
            textYPos.Text = ((int)(offset / Map.MAP_WIDTH)).ToString();
        }
    }
}
