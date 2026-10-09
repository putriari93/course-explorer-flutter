import 'package:flutter/material.dart';

CourseStatusInfo statusInfo(String status) {
  switch (status) {
    case 'done':
      return const CourseStatusInfo(
        label: 'Selesai',
        icon: Icons.menu_book_rounded,
        color: Colors.green,
      );

    case 'active':
      return const CourseStatusInfo(
        label: 'Aktif',
        icon: Icons.menu_book_rounded,
        color: Colors.orange,
      );

    default:
      return const CourseStatusInfo(
        label: 'Rencana',
        icon: Icons.menu_book_rounded,
        color: Colors.grey,
      );
  }
}

class CourseStatusInfo {
  const CourseStatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}
