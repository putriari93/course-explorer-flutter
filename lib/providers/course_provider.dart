import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;
  CourseProvider(this.repository);
  List<Course> _courses = [];
  List<Course> get courses => List.unmodifiable(_courses);
  bool isLoading = false;
  bool hasLoaded = false;
  String? error;
  bool _disposed = false;
  Future<void> loadCourses() async {
    if (isLoading || _disposed) return;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await repository.getCourses();
      if (_disposed) return;
      _courses = result;
      hasLoaded = true;
    } catch (exception) {
      if (!_disposed) error = 'Gagal memuat course. Silakan coba lagi.';
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

  final Set<String> _favorites = {};
  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool isFavorite(String code) => _favorites.contains(code);
  void toggleFavorite(String code) {
    if (!_favorites.add(code)) _favorites.remove(code);
    notifyListeners();
  }
}
