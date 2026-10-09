import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:latihan_1/main.dart';
import 'package:latihan_1/models/course.dart';
import 'package:latihan_1/providers/course_provider.dart';
import 'package:latihan_1/providers/student_provider.dart';
import 'package:latihan_1/repositories/course_repository.dart';
import 'package:latihan_1/repositories/student_repository.dart';
import 'package:latihan_1/services/course_service.dart';
import 'package:latihan_1/services/student_service.dart';

const fixtureCourses = [
  Course(code: 'MOB01', title: 'Git & GitHub', credits: 2, status: 'done'),
  Course(code: 'MOB02', title: 'Dart Fundamentals', credits: 2, status: 'done'),
  Course(
    code: 'MOB03',
    title: 'Flutter UI Fundamentals',
    credits: 3,
    status: 'active',
  ),
  Course(code: 'MOB04', title: 'Navigation', credits: 2, status: 'planned'),
  Course(
    code: 'MOB05',
    title: 'State Management',
    credits: 3,
    status: 'planned',
  ),
];

class FixtureCourseRepository extends CourseRepository {
  FixtureCourseRepository() : super(CourseService());
  int calls = 0;
  @override
  Future<List<Course>> getCourses() async {
    calls++;
    return fixtureCourses;
  }
}

class FixtureStudentRepository extends StudentRepository {
  FixtureStudentRepository() : super(StudentService());
  @override
  Future<Map<String, dynamic>> getStudent() async => {
    'name': 'Putri Ari Laksmi',
    'nim': '2415051091',
    'semester': 'Semester 5',
  };
}

Future<CourseProvider> pumpFixture(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final courseProvider = CourseProvider(FixtureCourseRepository());
  final studentProvider = StudentProvider(FixtureStudentRepository());
  await courseProvider.loadCourses();
  await studentProvider.loadStudent();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: courseProvider),
        ChangeNotifierProvider.value(value: studentProvider),
      ],
      child: const MyApp(),
    ),
  );
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    courseProvider.dispose();
    studentProvider.dispose();
  });
  await tester.pumpAndSettle();
  return courseProvider;
}

Future<void> selectPage(WidgetTester tester, String label) async {
  final nav = find.byType(NavigationBar).evaluate().isNotEmpty
      ? find.byType(NavigationBar)
      : find.byType(NavigationRail);
  await tester.tap(find.descendant(of: nav, matching: find.text(label)).last);
  await tester.pumpAndSettle();
}
