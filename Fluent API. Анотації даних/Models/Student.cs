namespace AcademyApp.Models;

public class Student
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public decimal ScholarshipType { get; set; }

    // звязок з групою
    public int GroupId { get; set; }
    public Group? Group { get; set; }

    // звязок з паспортом
    public Passport? Passport { get; set; }
}
