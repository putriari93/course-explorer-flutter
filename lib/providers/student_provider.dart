import 'package:flutter/foundation.dart';

import '../repositories/student_repository.dart';

class StudentProvider extends ChangeNotifier {
  final StudentRepository repository;
  StudentProvider(this.repository);
  Map<String, dynamic> _student = {};
  Map<String, dynamic> get student => Map.unmodifiable(_student);
  bool isLoading = false;
  String? error;
  bool _disposed = false;
  Future<void> loadStudent() async {
    if (isLoading || _disposed) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await repository.getStudent();
      if (!_disposed) _student = result;
    } catch (_) {
      if (!_disposed) error = 'Gagal memuat profil. Silakan coba lagi.';
    } finally {
      isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
