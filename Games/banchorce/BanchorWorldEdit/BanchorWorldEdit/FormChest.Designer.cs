namespace BanchorWorldEdit
{
    partial class FormChest
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(FormChest));
            this.labelTalkId = new System.Windows.Forms.Label();
            this.buttonCancel = new System.Windows.Forms.Button();
            this.buttonOK = new System.Windows.Forms.Button();
            this.groupPosition = new System.Windows.Forms.GroupBox();
            this.textXPos = new System.Windows.Forms.TextBox();
            this.textYPos = new System.Windows.Forms.TextBox();
            this.labelPosX = new System.Windows.Forms.Label();
            this.labelPosY = new System.Windows.Forms.Label();
            this.buttonUp = new System.Windows.Forms.Button();
            this.buttonDown = new System.Windows.Forms.Button();
            this.buttonRight = new System.Windows.Forms.Button();
            this.buttonLeft = new System.Windows.Forms.Button();
            this.comboBoxItem = new System.Windows.Forms.ComboBox();
            this.groupPosition.SuspendLayout();
            this.SuspendLayout();
            // 
            // labelTalkId
            // 
            this.labelTalkId.AutoSize = true;
            this.labelTalkId.Location = new System.Drawing.Point(234, 48);
            this.labelTalkId.Name = "labelTalkId";
            this.labelTalkId.Size = new System.Drawing.Size(40, 13);
            this.labelTalkId.TabIndex = 11;
            this.labelTalkId.Text = "Item #:";
            // 
            // buttonCancel
            // 
            this.buttonCancel.Location = new System.Drawing.Point(320, 85);
            this.buttonCancel.Name = "buttonCancel";
            this.buttonCancel.Size = new System.Drawing.Size(83, 34);
            this.buttonCancel.TabIndex = 10;
            this.buttonCancel.Text = "Cancel";
            this.buttonCancel.UseVisualStyleBackColor = true;
            this.buttonCancel.Click += new System.EventHandler(this.buttonCancel_Click);
            // 
            // buttonOK
            // 
            this.buttonOK.Location = new System.Drawing.Point(231, 85);
            this.buttonOK.Name = "buttonOK";
            this.buttonOK.Size = new System.Drawing.Size(83, 34);
            this.buttonOK.TabIndex = 9;
            this.buttonOK.Text = "Save";
            this.buttonOK.UseVisualStyleBackColor = true;
            this.buttonOK.Click += new System.EventHandler(this.buttonOK_Click);
            // 
            // groupPosition
            // 
            this.groupPosition.Controls.Add(this.textXPos);
            this.groupPosition.Controls.Add(this.textYPos);
            this.groupPosition.Controls.Add(this.labelPosX);
            this.groupPosition.Controls.Add(this.labelPosY);
            this.groupPosition.Controls.Add(this.buttonUp);
            this.groupPosition.Controls.Add(this.buttonDown);
            this.groupPosition.Controls.Add(this.buttonRight);
            this.groupPosition.Controls.Add(this.buttonLeft);
            this.groupPosition.Location = new System.Drawing.Point(12, 12);
            this.groupPosition.Name = "groupPosition";
            this.groupPosition.Size = new System.Drawing.Size(206, 143);
            this.groupPosition.TabIndex = 13;
            this.groupPosition.TabStop = false;
            this.groupPosition.Text = "Position";
            // 
            // textXPos
            // 
            this.textXPos.Location = new System.Drawing.Point(33, 40);
            this.textXPos.Name = "textXPos";
            this.textXPos.ReadOnly = true;
            this.textXPos.Size = new System.Drawing.Size(37, 20);
            this.textXPos.TabIndex = 4;
            this.textXPos.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // textYPos
            // 
            this.textYPos.Location = new System.Drawing.Point(33, 66);
            this.textYPos.Name = "textYPos";
            this.textYPos.ReadOnly = true;
            this.textYPos.Size = new System.Drawing.Size(37, 20);
            this.textYPos.TabIndex = 5;
            this.textYPos.TextAlign = System.Windows.Forms.HorizontalAlignment.Right;
            // 
            // labelPosX
            // 
            this.labelPosX.AutoSize = true;
            this.labelPosX.Location = new System.Drawing.Point(10, 43);
            this.labelPosX.Name = "labelPosX";
            this.labelPosX.Size = new System.Drawing.Size(17, 13);
            this.labelPosX.TabIndex = 4;
            this.labelPosX.Text = "X:";
            // 
            // labelPosY
            // 
            this.labelPosY.AutoSize = true;
            this.labelPosY.Location = new System.Drawing.Point(10, 69);
            this.labelPosY.Name = "labelPosY";
            this.labelPosY.Size = new System.Drawing.Size(17, 13);
            this.labelPosY.TabIndex = 5;
            this.labelPosY.Text = "Y:";
            // 
            // buttonUp
            // 
            this.buttonUp.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("buttonUp.BackgroundImage")));
            this.buttonUp.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.buttonUp.Location = new System.Drawing.Point(125, 26);
            this.buttonUp.Name = "buttonUp";
            this.buttonUp.Size = new System.Drawing.Size(32, 32);
            this.buttonUp.TabIndex = 7;
            this.buttonUp.UseVisualStyleBackColor = true;
            this.buttonUp.Click += new System.EventHandler(this.buttonUp_Click);
            // 
            // buttonDown
            // 
            this.buttonDown.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("buttonDown.BackgroundImage")));
            this.buttonDown.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.buttonDown.Location = new System.Drawing.Point(125, 93);
            this.buttonDown.Name = "buttonDown";
            this.buttonDown.Size = new System.Drawing.Size(32, 32);
            this.buttonDown.TabIndex = 8;
            this.buttonDown.UseVisualStyleBackColor = true;
            this.buttonDown.Click += new System.EventHandler(this.buttonDown_Click);
            // 
            // buttonRight
            // 
            this.buttonRight.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("buttonRight.BackgroundImage")));
            this.buttonRight.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.buttonRight.Location = new System.Drawing.Point(161, 59);
            this.buttonRight.Name = "buttonRight";
            this.buttonRight.Size = new System.Drawing.Size(32, 32);
            this.buttonRight.TabIndex = 10;
            this.buttonRight.UseVisualStyleBackColor = true;
            this.buttonRight.Click += new System.EventHandler(this.buttonRight_Click);
            // 
            // buttonLeft
            // 
            this.buttonLeft.BackgroundImage = ((System.Drawing.Image)(resources.GetObject("buttonLeft.BackgroundImage")));
            this.buttonLeft.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.buttonLeft.Location = new System.Drawing.Point(87, 59);
            this.buttonLeft.Name = "buttonLeft";
            this.buttonLeft.Size = new System.Drawing.Size(32, 32);
            this.buttonLeft.TabIndex = 9;
            this.buttonLeft.UseVisualStyleBackColor = true;
            this.buttonLeft.Click += new System.EventHandler(this.buttonLeft_Click);
            // 
            // comboBoxItem
            // 
            this.comboBoxItem.DropDownStyle = System.Windows.Forms.ComboBoxStyle.DropDownList;
            this.comboBoxItem.FormattingEnabled = true;
            this.comboBoxItem.Items.AddRange(new object[] {
            "Nothing to sell",
            "Blunt Sword",
            "Superior Sword",
            "Legendary Sword",
            "Wooden Shield",
            "Iron Shield",
            "Light Armor",
            "Heavy Armor",
            "Aqua Boots",
            "Winged Boots",
            "Ring of Might",
            "Ring of Thunder",
            "Heart Piece",
            "Crystal 1",
            "Crystal 2",
            "Crystal 3",
            "Crystal 4",
            "Crystal 5",
            "Crystal 6",
            "Crystal 7",
            "Heart Container 1",
            "Heart Container 2",
            "Heart Container 3",
            "1000 Gold",
            "5000 Gold",
            "10000 Gold",
            "Full Life Refill",
            "Well"});
            this.comboBoxItem.Location = new System.Drawing.Point(280, 45);
            this.comboBoxItem.Name = "comboBoxItem";
            this.comboBoxItem.Size = new System.Drawing.Size(121, 21);
            this.comboBoxItem.TabIndex = 14;
            // 
            // FormChest
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(412, 166);
            this.Controls.Add(this.comboBoxItem);
            this.Controls.Add(this.groupPosition);
            this.Controls.Add(this.labelTalkId);
            this.Controls.Add(this.buttonCancel);
            this.Controls.Add(this.buttonOK);
            this.Name = "FormChest";
            this.ShowIcon = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "Edit Chest";
            this.groupPosition.ResumeLayout(false);
            this.groupPosition.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion
        private System.Windows.Forms.Label labelTalkId;
        private System.Windows.Forms.Button buttonCancel;
        private System.Windows.Forms.Button buttonOK;
        private System.Windows.Forms.GroupBox groupPosition;
        private System.Windows.Forms.TextBox textXPos;
        private System.Windows.Forms.TextBox textYPos;
        private System.Windows.Forms.Label labelPosX;
        private System.Windows.Forms.Label labelPosY;
        private System.Windows.Forms.Button buttonUp;
        private System.Windows.Forms.Button buttonDown;
        private System.Windows.Forms.Button buttonRight;
        private System.Windows.Forms.Button buttonLeft;
        private System.Windows.Forms.ComboBox comboBoxItem;
    }
}