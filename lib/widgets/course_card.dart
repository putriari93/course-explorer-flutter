import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../models/course.dart';
import '../screens/course_detail_page.dart';
import 'course_status.dart';

class CourseCard extends StatefulWidget {
  const CourseCard({
    super.key,
    required this.course,
    this.showFavorite = true,
    this.showStatus = false,
  });
  final Course course;
  final bool showFavorite;
  final bool showStatus;
  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool isNavigating = false;
  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final status = statusInfo(course.status);
    final courseCode = course.code;
    final (homeStatus, homeIcon) = switch (course.status) {
      'done' => ('done', Icons.check_circle_outline),
      'active' => ('active', Icons.play_circle_outline),
      _ => ('waiting', Icons.schedule),
    };
    return GestureDetector(
      onLongPress: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${course.title} • $courseCode • ${course.credits} SKS',
          ),
        ),
      ),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () async {
            if (isNavigating) return;
            setState(() => isNavigating = true);
            await Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CourseDetailPage(course: course),
              ),
            );
            if (!mounted || !context.mounted) return;
            setState(() => isNavigating = false);
          },
          child: ListTile(
            leading: Icon(
              widget.showStatus ? homeIcon : status.icon,
              color: status.color,
            ),
            title: Text(
              course.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: widget.showStatus
                ? Text(homeStatus, style: TextStyle(color: status.color))
                : Text('$courseCode • ${course.credits} SKS'),
            // watch membaca jumlah pada halaman, Consumer mendengar ikon, read menjalankan aksi.
            trailing: widget.showFavorite
                ? Consumer<CourseProvider>(
                    builder: (context, provider, child) {
                      final isFavorite = provider.isFavorite(courseCode);
                      return IconButton(
                        tooltip: isFavorite
                            ? 'Hapus dari favorite'
                            : 'Tambahkan ke favorite',
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          context.read<CourseProvider>().toggleFavorite(
                            courseCode,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isFavorite
                                    ? '${course.title} dihapus dari favorite'
                                    : '${course.title} ditambahkan ke favorite',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
