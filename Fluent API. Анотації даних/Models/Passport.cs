namespace AcademyApp.Models;

public class Passport
{
    public int Id { get; set; }
    public string Number { get; set; } = string.Empty;

    // звязок зі студентом (один до одного)
    public int StudentId { get; set; }
    public Student? Student { get; set; }
}
