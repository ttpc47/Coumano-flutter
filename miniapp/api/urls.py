from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DepartmentViewSet, SpecialityViewSet, StudentViewSet

# Create a router instance
router = DefaultRouter()
router.register(r'departments', DepartmentViewSet, basename='department')
router.register(r'specialities', SpecialityViewSet, basename='speciality')
router.register(r'students', StudentViewSet, basename='student')

urlpatterns = [
      path('', include(router.urls)),
  ]     