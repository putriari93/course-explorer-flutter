import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course.dart';

class CourseService {
  Future<List<Course>> loadCourses() async {
    final source = await rootBundle.loadString('assets/data/student_data.json');
    final json = jsonDecode(source) as Map<String, dynamic>;
    return (json['courses'] as List<dynamic>)
        .map((value) => Course.fromJson(value as Map<String, dynamic>))
        .toList();
  }
}
