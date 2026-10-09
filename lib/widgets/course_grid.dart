import 'package:flutter/material.dart';

import '../models/course.dart';
import 'course_card.dart';

class CourseGrid extends StatelessWidget {
  const CourseGrid({
    super.key,
    required this.courses,
    this.showFavorite = true,
    this.showStatus = false,
  });
  final List<Course> courses;
  final bool showFavorite;
  final bool showStatus;
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

        const itemHeight = 136.0;

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
            return CourseCard(
              key: showStatus
                  ? ValueKey('home-course-${courses[index].code}')
                  : null,
              course: courses[index],
              showFavorite: showFavorite,
              showStatus: showStatus,
            );
          },
        );
      },
    );
  }
}
