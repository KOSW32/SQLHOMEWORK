namespace UserManagerWinForms;

using System;
using System.Windows.Forms;
public partial class Form1 : Form
{
 public Form1(){InitializeComponent();}
 private void btnAdd_Click(object sender, EventArgs e)
 {
  listBox1.Items.Add(txtUsername.Text + " | " + txtEmail.Text + " | " + dtBirth.Value.ToShortDateString());
 }
 private void btnSearch_Click(object sender, EventArgs e)
 {
  foreach(var item in listBox1.Items)
   if(item.ToString()!.Contains(txtSearch.Text)){MessageBox.Show(item.ToString()); return;}
  MessageBox.Show("Не знайдено");
 }
 private void btnDelete_Click(object sender, EventArgs e)
 {
  for(int i=listBox1.Items.Count-1;i>=0;i--)
   if(listBox1.Items[i].ToString()!.Contains(txtSearch.Text)) listBox1.Items.RemoveAt(i);
 }
}