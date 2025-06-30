from rest_framework import serializers
from .models import Department, Speciality, Student

class DepartmentSerializer(serializers.ModelSerializer):
   
    specialties_names = serializers.StringRelatedField(many=True, source='specialties', read_only=True)

    class Meta:
        model = Department
        fields = '__all__' 
class SpecialitySerializer(serializers.ModelSerializer):

    department_name = serializers.ReadOnlyField(source='department.name')
    students_names = serializers.StringRelatedField(many=True, source='students', read_only=True)

    class Meta:
        model = Speciality
        fields = '__all__'
class StudentSerializer(serializers.ModelSerializer):
   
    speciality_name = serializers.ReadOnlyField(source='speciality.name')
    department_name = serializers.ReadOnlyField(source='speciality.department.name')

    class Meta:
        model = Student
        fields = '__all__'