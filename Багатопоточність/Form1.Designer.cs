namespace Багатопоточність
{
    partial class Form1
    {
        /// <summary>
        ///  Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        ///  Clean up any resources being used.
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
        ///  Required method for Designer support - do not modify
        ///  the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            btnStart = new Button();
            btnCancel = new Button();
            labelStatus = new Label();
            textBoxPath = new TextBox();
            textBoxShift = new TextBox();
            SuspendLayout();
            // 
            // btnStart
            // 
            btnStart.Location = new Point(12, 142);
            btnStart.Name = "btnStart";
            btnStart.Size = new Size(75, 23);
            btnStart.TabIndex = 0;
            btnStart.Text = "Старт";
            btnStart.UseVisualStyleBackColor = true;
            btnStart.Click += btnStart_Click;
            // 
            // btnCancel
            // 
            btnCancel.Location = new Point(115, 142);
            btnCancel.Name = "btnCancel";
            btnCancel.Size = new Size(75, 23);
            btnCancel.TabIndex = 1;
            btnCancel.Text = "Отмена";
            btnCancel.UseVisualStyleBackColor = true;
            btnCancel.Click += ;
            // 
            // labelStatus
            // 
            labelStatus.AutoSize = true;
            labelStatus.Location = new Point(12, 209);
            labelStatus.Name = "labelStatus";
            labelStatus.Size = new Size(64, 15);
            labelStatus.TabIndex = 2;
            labelStatus.Text = "Ожидание";
            labelStatus.Click += ;
            // 
            // textBoxPath
            // 
            textBoxPath.Location = new Point(12, 42);
            textBoxPath.Name = "textBoxPath";
            textBoxPath.Size = new Size(100, 23);
            textBoxPath.TabIndex = 3;
            // 
            // textBoxShift
            // 
            textBoxShift.Location = new Point(12, 71);
            textBoxShift.Name = "textBoxShift";
            textBoxShift.Size = new Size(100, 23);
            textBoxShift.TabIndex = 4;
            // 
            // Form1
            // 
            AutoScaleDimensions = new SizeF(7F, 15F);
            AutoScaleMode = AutoScaleMode.Font;
            ClientSize = new Size(800, 450);
            Controls.Add(textBoxShift);
            Controls.Add(textBoxPath);
            Controls.Add(labelStatus);
            Controls.Add(btnCancel);
            Controls.Add(btnStart);
            Name = "Form1";
            Text = "Form1";
            ResumeLayout(false);
            PerformLayout();
        }

        #endregion

        private Button btnStart;
        private Button btnCancel;
        private Label labelStatus;
        private TextBox textBoxPath;
        private TextBox textBoxShift;
    }
}
