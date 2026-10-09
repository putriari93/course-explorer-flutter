import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/identity_card.dart';
import '../widgets/course_grid.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IdentityCard(),
          const SizedBox(height: 16),
          Text(
            'Daftar Course • Favorite: ${provider.favorites.length}',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null) ...[
            Text(provider.error!),
            FilledButton(
              onPressed: () => context.read<CourseProvider>().loadCourses(),
              child: const Text('Coba lagi'),
            ),
          ] else
            CourseGrid(courses: provider.courses),
        ],
      ),
    );
  }
}
