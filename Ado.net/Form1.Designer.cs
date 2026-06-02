namespace UserManagerWinForms;

using System.Windows.Forms;
using System.Drawing;
partial class Form1
{
 private TextBox txtUsername,txtEmail,txtSearch;
 private DateTimePicker dtBirth;
 private Button btnAdd,btnSearch,btnDelete;
 private ListBox listBox1;

 private void InitializeComponent()
 {
 txtUsername=new TextBox(){Left=20,Top=20,Width=150};
 txtEmail=new TextBox(){Left=20,Top=60,Width=150};
 dtBirth=new DateTimePicker(){Left=20,Top=100,Width=150};
 txtSearch=new TextBox(){Left=20,Top=140,Width=150};
 btnAdd=new Button(){Left=20,Top=180,Text="Додати"};
 btnSearch=new Button(){Left=100,Top=180,Text="Пошук"};
 btnDelete=new Button(){Left=180,Top=180,Text="Видалити"};
 listBox1=new ListBox(){Left=250,Top=20,Width=350,Height=220};
 btnAdd.Click+=btnAdd_Click;
 btnSearch.Click+=btnSearch_Click;
 btnDelete.Click+=btnDelete_Click;
 Controls.AddRange(new Control[]{txtUsername,txtEmail,dtBirth,txtSearch,btnAdd,btnSearch,btnDelete,listBox1});
 Text="User Manager";
 ClientSize=new Size(620,280);
 }
}