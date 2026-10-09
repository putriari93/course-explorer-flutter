import 'dart:convert';

import 'package:flutter/services.dart';

class StudentService {
  Future<Map<String, dynamic>> loadStudent() async {
    final source = await rootBundle.loadString('assets/data/student_data.json');
    return (jsonDecode(source) as Map<String, dynamic>)['student']
        as Map<String, dynamic>;
  }
}
