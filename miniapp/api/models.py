import uuid
from django.db import models

class Department(models.Model):
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=255, unique=True, help_text="Name of the department")
    code = models.CharField(max_length=50, unique=True, help_text="Unique code for the department")
    description = models.TextField(blank=True, null=True, help_text="Optional description of the department")
    established_date = models.DateField(blank=True, null=True, help_text="Date the department was established")

    class Meta:
        verbose_name = "Department"
        verbose_name_plural = "Departments"
        ordering = ['name']

    def __str__(self):
        return self.name

class Speciality(models.Model):
    uuid = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    department = models.ForeignKey(
        Department,
        on_delete=models.CASCADE,
        related_name='specialties',
    )
    name = models.CharField(max_length=255,)
    code = models.CharField(max_length=50, unique=True)
    duration_years = models.IntegerField(default=3, )
    is_active = models.BooleanField(default=True,)

    class Meta:
        verbose_name = "Speciality"
        verbose_name_plural = "Specialties"
        unique_together = ('department', 'name')
        ordering = ['name']

    def __str__(self):
        return f"{self.name} ({self.department.name})"

class Student(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    speciality = models.ForeignKey(
        Speciality,
        on_delete=models.CASCADE,
        related_name='students',
        help_text="The speciality the student is enrolled in"
    )
    first_name = models.CharField(max_length=100, )
    last_name = models.CharField(max_length=100, )
    student_id = models.CharField(
        max_length=20,
        unique=True,
        default="stud",
        help_text="Unique identifier for the student, e.g., student ID"
    )
    email = models.EmailField(unique=True)
    date_of_birth = models.DateField(blank=True, null=True,)
    enrollment_date = models.DateField(auto_now_add=True,)

    class Meta:
        verbose_name = "Student"
        verbose_name_plural = "Students"
        unique_together = ('first_name', 'last_name', 'date_of_birth')
        ordering = ['last_name', 'first_name']

    def __str__(self):
        return f"{self.first_name} {self.last_name} ({self.student_id})"
