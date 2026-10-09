import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:latihan_1/models/course.dart';
import 'package:latihan_1/providers/course_provider.dart';
import 'package:latihan_1/repositories/course_repository.dart';
import 'package:latihan_1/services/course_service.dart';
import 'package:latihan_1/screens/courses_page.dart';
import 'package:latihan_1/widgets/course_card.dart';

import 'support/app_fixture.dart';

class RetryRepository extends CourseRepository {
  RetryRepository() : super(CourseService());
  Completer<List<Course>> result = Completer<List<Course>>();
  int calls = 0;
  @override
  Future<List<Course>> getCourses() {
    calls++;
    return result.future;
  }
}

void main() {
  testWidgets('Courses menampilkan loading, error dan retry sukses', (
    tester,
  ) async {
    final repository = RetryRepository();
    final provider = CourseProvider(repository);
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    });
    final loading = provider.loadCourses();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: Scaffold(body: CoursesPage())),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Putri Ari Laksmi'), findsOneWidget);
    repository.result.completeError(StateError('Simulasi gagal'));
    await loading;
    await tester.pumpAndSettle();
    expect(
      find.text('Gagal memuat course. Silakan coba lagi.'),
      findsOneWidget,
    );
    repository.result = Completer<List<Course>>();
    await tester.tap(find.text('Coba lagi'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    repository.result.complete(fixtureCourses);
    await tester.pumpAndSettle();
    expect(repository.calls, 2);
    expect(find.byType(CourseCard), findsNWidgets(5));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Coba lagi'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
