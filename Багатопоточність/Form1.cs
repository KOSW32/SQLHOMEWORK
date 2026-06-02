using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Багатопоточність
{
    public partial class Form1 : Form
    {
        CancellationTokenSource cts;

        public Form1()
        {
            InitializeComponent();
        }

        private async void btnStart_Click(object sender, EventArgs e)
        {
            string path = textBoxPath.Text;

            if (string.IsNullOrWhiteSpace(path) || !File.Exists(path))
            {
                labelStatus.Text = "Файл не найден";
                return;
            }

            if (!int.TryParse(textBoxShift.Text, out int shift))
            {
                labelStatus.Text = "Неверный ключ";
                return;
            }

            cts = new CancellationTokenSource();

            labelStatus.Text = "Шифрование...";

            try
            {
                await Task.Run(() => EncryptFile(path, shift, cts.Token));
                labelStatus.Text = "Готово";
            }
            catch (OperationCanceledException)
            {
                labelStatus.Text = "Отменено";
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            cts?.Cancel();
        }

        void EncryptFile(string path, int shift, CancellationToken token)
        {
            string text = File.ReadAllText(path);
            char[] result = new char[text.Length];

            for (int i = 0; i < text.Length; i++)
            {
                token.ThrowIfCancellationRequested();

                char c = text[i];

                if (char.IsLetter(c))
                {
                    char offset = char.IsUpper(c) ? 'A' : 'a';
                    result[i] = (char)((c - offset + shift) % 26 + offset);
                }
                else
                {
                    result[i] = c;
                }

                Thread.Sleep(20);
            }

            File.WriteAllText(path + ".enc.txt", new string(result));
        }
    }
}