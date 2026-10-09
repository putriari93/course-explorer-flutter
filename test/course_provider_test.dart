import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:latihan_1/providers/course_provider.dart';
import 'package:latihan_1/repositories/course_repository.dart';
import 'package:latihan_1/services/course_service.dart';
import 'package:latihan_1/models/course.dart';

void main() {
  test('Favorite memberi notifikasi dan koleksi tidak bisa diubah dari luar', () {
    final provider = CourseProvider(CourseRepository(CourseService()));
    addTearDown(provider.dispose);
    var notifications = 0;
    provider.addListener(() => notifications++);
    provider.toggleFavorite('MOB01');
    expect(provider.isFavorite('MOB01'), isTrue);
    expect(notifications, 1);
    expect(() => provider.favorites.add('MOB02'), throwsUnsupportedError);
    provider.toggleFavorite('MOB01');
    expect(provider.favorites, isEmpty);
    expect(notifications, 2);
  });

  test('Loading, error, retry, success dan pemanggilan ganda', () async {
    final repository = ControlledRepository();
    final provider = CourseProvider(repository);
    addTearDown(provider.dispose);
    expect(provider.hasLoaded, isFalse);
    final loading = provider.loadCourses();
    expect(provider.isLoading, isTrue);
    await provider.loadCourses();
    expect(repository.calls, 1);
    repository.result.completeError(StateError('Data gagal'));
    await loading;
    expect(provider.error, isNotNull);
    expect(provider.isLoading, isFalse);
    repository.result = Completer<List<Course>>();
    final retry = provider.loadCourses();
    expect(provider.error, isNull);
    repository.result.complete([const Course(code: 'MOB01', title: 'Git & GitHub', credits: 2, status: 'done')]);
    await retry;
    expect(provider.hasLoaded, isTrue);
    expect(provider.courses.length, 1);
    expect(() => provider.courses.clear(), throwsUnsupportedError);
  });
  test('Async selesai setelah dispose tidak memberi notifikasi', () async {
    final repository = ControlledRepository();
    final provider = CourseProvider(repository);
    final pending = provider.loadCourses();
    provider.dispose();
    repository.result.complete([]);
    await pending;
  });
}
class ControlledRepository extends CourseRepository {
  ControlledRepository() : super(CourseService());
  Completer<List<Course>> result = Completer<List<Course>>();
  int calls = 0;
  @override
  Future<List<Course>> getCourses() {
    calls++;
    return result.future;
  }
}
