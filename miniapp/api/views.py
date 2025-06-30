from django.shortcuts import render


from rest_framework import viewsets
from .models import Department, Speciality, Student
from .serializers import DepartmentSerializer, SpecialitySerializer, StudentSerializer

class DepartmentViewSet(viewsets.ModelViewSet):
    queryset = Department.objects.all() 
    serializer_class = DepartmentSerializer
    
class SpecialityViewSet(viewsets.ModelViewSet):
 
    queryset = Speciality.objects.all()
    serializer_class = SpecialitySerializer

class StudentViewSet(viewsets.ModelViewSet):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer
    
