import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:latihan_1/main.dart';
import 'package:latihan_1/providers/course_provider.dart';
import 'package:latihan_1/providers/student_provider.dart';
import 'package:latihan_1/screens/home_page.dart';

void main() {
  testWidgets('Bootstrap root memuat course dan profil dari asset asli', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(createApp());
      final context = tester.element(find.byType(HomePage));
      final courses = context.read<CourseProvider>();
      final student = context.read<StudentProvider>();
      for (
        var attempt = 0;
        attempt < 1000 && (courses.isLoading || student.isLoading);
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(courses.isLoading, isFalse);
      expect(courses.error, isNull);
      expect(courses.courses.length, greaterThanOrEqualTo(5));
      expect(student.error, isNull);
      expect(student.student['nim'], '2415051091');
    });
    await tester.pumpAndSettle();
    expect(find.text('Course Explorer v2'), findsOneWidget);
    expect(find.text('Putri Ari Laksmi'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
