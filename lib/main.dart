import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'providers/student_provider.dart';
import 'repositories/course_repository.dart';
import 'repositories/student_repository.dart';
import 'services/course_service.dart';
import 'services/student_service.dart';
import 'screens/dashboard_page.dart';

void main() => runApp(createApp());

Widget createApp() => MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) =>
          CourseProvider(CourseRepository(CourseService()))..loadCourses(),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          StudentProvider(StudentRepository(StudentService()))..loadStudent(),
    ),
  ],
  child: const MyApp(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer v2',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}
