import 'package:flutter/foundation.dart';

class CourseProvider extends ChangeNotifier {
  final Set<String> _favorites = {};
  Set<String> get favorites => Set.unmodifiable(_favorites);
  bool isFavorite(String code) => _favorites.contains(code);
  void toggleFavorite(String code) {
    if (!_favorites.add(code)) _favorites.remove(code);
    notifyListeners();
  }
}
