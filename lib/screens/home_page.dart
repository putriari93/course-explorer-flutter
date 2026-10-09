import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';
import '../widgets/identity_card.dart';
import '../widgets/state_demos.dart';
import '../widgets/responsive_layout_demo.dart';
import '../widgets/flexible_layout_demo.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final courses = context.watch<CourseProvider>().courses;
    final completedCount = courses
        .where((course) => course.status == 'done')
        .length;
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    final layoutType = size.width < 600
        ? 'Compact'
        : size.width < 840
        ? 'Medium'
        : 'Expanded';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IdentityCard(),
          const SizedBox(height: 12),
          Text(
            'Jumlah favorite: ${context.watch<CourseProvider>().favorites.length}',
          ),
          const ChangeNotifierDemo(),
          const LocalStateDemo(),
          const FavoriteStateDemo(),
          const FavoriteCounterNotifierDemo(),

          const SizedBox(height: 12),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Layar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 8),

                  Text('Width: ${size.width.toStringAsFixed(0)}'),

                  Text('Height: ${size.height.toStringAsFixed(0)}'),

                  Text('Orientation: $orientation'),

                  Text('Layout: $layoutType'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          const ResponsiveLayoutDemo(),

          const SizedBox(height: 12),

          const FlexibleLayoutDemo(),

          const SizedBox(height: 12),

          Row(
            children: [
              _buildSummaryCard(
                value: '${courses.length}',
                label: 'Topik',
                icon: Icons.menu_book_rounded,
              ),

              const SizedBox(width: 12),

              _buildSummaryCard(
                value: '$completedCount',
                label: 'Selesai',
                icon: Icons.task_alt_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Icon(icon),

              const SizedBox(height: 6),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
