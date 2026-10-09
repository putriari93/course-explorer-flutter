import '../services/student_service.dart';

class StudentRepository {
  final StudentService service;
  StudentRepository(this.service);
  Future<Map<String, dynamic>> getStudent() => service.loadStudent();
}
