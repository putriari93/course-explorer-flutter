import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../debug/state_debug_lab.dart';
import '../widgets/course_grid.dart';
import '../providers/course_provider.dart';
import '../widgets/identity_card.dart';
import '../widgets/responsive_layout_demo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final courses = provider.courses;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IdentityCard(),
          const SizedBox(height: 12),
          Row(
            key: const ValueKey('home-statistics'),
            children: [
              _buildSummaryCard(
                id: 'courses',
                value: '${courses.length}',
                label: 'Courses',
                icon: Icons.menu_book_rounded,
              ),
              const SizedBox(width: 4),
              _buildSummaryCard(
                id: 'favorites',
                value: '${provider.favorites.length}',
                label: 'Favorites',
                icon: Icons.favorite,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Daftar Course', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (provider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (provider.error != null)
            Column(
              children: [
                Text(provider.error!),
                TextButton(
                  onPressed: provider.loadCourses,
                  child: const Text('Coba lagi'),
                ),
              ],
            )
          else
            CourseGrid(courses: courses, showFavorite: false, showStatus: true),
          const SizedBox(height: 12),
          const ResponsiveLayoutDemo(),
          if (kDebugMode) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const StateDebugLab()),
              ),
              icon: const Icon(Icons.bug_report_outlined),
              label: const Text('State Debug Lab'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String id,
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        key: ValueKey('home-stat-$id'),
        margin: EdgeInsets.zero,
        child: SizedBox(
          height: 110,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              children: [
                Icon(icon, size: 20),
                const SizedBox(height: 4),
                FittedBox(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
