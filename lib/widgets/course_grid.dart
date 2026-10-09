import 'package:flutter/material.dart';

import '../models/course.dart';
import 'course_card.dart';

class CourseGrid extends StatelessWidget {
  const CourseGrid({super.key, required this.courses});
  final List<Course> courses;
  int columnsFor(double width) => width < 600
      ? 1
      : width < 840
      ? 2
      : 3;
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(MediaQuery.sizeOf(context).width);

        final itemHeight = constraints.maxWidth < 600
            ? 120.0
            : constraints.maxWidth < 840
            ? 115.0
            : 110.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: itemHeight,
          ),
          itemCount: courses.length,
          itemBuilder: (context, index) {
            return CourseCard(course: courses[index]);
          },
        );
      },
    );
  }
}
