import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/course_provider.dart';

class LocalStateDemo extends StatefulWidget {
  const LocalStateDemo({super.key});
  @override
  State<LocalStateDemo> createState() => _LocalStateDemoState();
}

class _LocalStateDemoState extends State<LocalStateDemo> {
  bool showDetail = false;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Local State Demo',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                showDetail = !showDetail;
              });
            },
            child: Text(showDetail ? 'Sembunyikan Detail' : 'Tampilkan Detail'),
          ),
          if (showDetail)
            const Text(
              'State ini hanya mengubah panel demo. Favorite digunakan bersama beberapa halaman.',
            ),
        ],
      ),
    ),
  );
}

class FavoritePropDrillingDemo extends StatelessWidget {
  // Data dan callback diteruskan lewat constructor sampai tile (dua level).
  const FavoritePropDrillingDemo({
    super.key,
    required this.favoriteCourses,
    required this.onToggle,
  });
  final Set<String> favoriteCourses;
  final ValueChanged<String> onToggle;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text('Favorite Prop Drilling Demo'),
          FavoriteCourseListDemo(
            favoriteCourses: favoriteCourses,
            onToggle: onToggle,
          ),
          FavoriteSummaryDemo(favoriteCourses: favoriteCourses),
        ],
      ),
    ),
  );
}

class FavoriteCourseListDemo extends StatelessWidget {
  const FavoriteCourseListDemo({
    super.key,
    required this.favoriteCourses,
    required this.onToggle,
  });
  final Set<String> favoriteCourses;
  final ValueChanged<String> onToggle;
  @override
  Widget build(BuildContext context) => FavoriteCourseTileDemo(
    favoriteCourses: favoriteCourses,
    onToggle: onToggle,
  );
}

class FavoriteCourseTileDemo extends StatelessWidget {
  const FavoriteCourseTileDemo({
    super.key,
    required this.favoriteCourses,
    required this.onToggle,
  });
  final Set<String> favoriteCourses;
  final ValueChanged<String> onToggle;
  @override
  Widget build(BuildContext context) => ListTile(
    title: const Text('Git & GitHub'),
    subtitle: const Text('MOB01'),
    trailing: IconButton(
      tooltip: 'Toggle favorite demo',
      onPressed: () => onToggle('MOB01'),
      icon: Icon(
        favoriteCourses.contains('MOB01')
            ? Icons.favorite
            : Icons.favorite_border,
      ),
    ),
  );
}

class FavoriteSummaryDemo extends StatelessWidget {
  const FavoriteSummaryDemo({super.key, required this.favoriteCourses});
  final Set<String> favoriteCourses;
  @override
  Widget build(BuildContext context) =>
      Text('Favorite demo: ${favoriteCourses.length}');
}

class FavoriteStateDemo extends StatefulWidget {
  const FavoriteStateDemo({super.key});
  @override
  State<FavoriteStateDemo> createState() => _FavoriteStateDemoState();
}

class _FavoriteStateDemoState extends State<FavoriteStateDemo> {
  // Satu pemilik state demo; list dan summary tidak menyalin state.
  final Set<String> favorites = {};
  @override
  Widget build(BuildContext context) => FavoritePropDrillingDemo(
    favoriteCourses: favorites,
    onToggle: (code) => setState(() {
      if (!favorites.add(code)) favorites.remove(code);
    }),
  );
}

class FavoriteCounterNotifierDemo extends StatefulWidget {
  const FavoriteCounterNotifierDemo({super.key});
  @override
  State<FavoriteCounterNotifierDemo> createState() =>
      _FavoriteCounterNotifierDemoState();
}

class _FavoriteCounterNotifierDemoState
    extends State<FavoriteCounterNotifierDemo> {
  final ValueNotifier<int> favoriteCounter = ValueNotifier<int>(0);
  @override
  void dispose() {
    favoriteCounter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const Text('ValueNotifier Demo'),
          ValueListenableBuilder<int>(
            valueListenable: favoriteCounter,
            builder: (context, value, child) =>
                Text('Counter favorite: $value'),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => favoriteCounter.value++,
                child: const Text('Tambah'),
              ),
              TextButton(
                onPressed: () {
                  if (favoriteCounter.value > 0) favoriteCounter.value--;
                },
                child: const Text('Kurangi'),
              ),
              TextButton(
                onPressed: () => favoriteCounter.value = 0,
                child: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class ChangeNotifierDemo extends StatelessWidget {
  const ChangeNotifierDemo({super.key});
  @override
  Widget build(BuildContext context) {
    // Instance yang sama dengan root, bukan CourseProvider kedua.
    final courseProvider = context.read<CourseProvider>();
    return ListenableBuilder(
      listenable: courseProvider,
      builder: (context, child) => Card(
        child: ListTile(
          title: const Text('ChangeNotifier Demo'),
          subtitle: Text('Favorite: ${courseProvider.favorites.length}'),
          trailing: IconButton(
            tooltip: 'Toggle ChangeNotifier demo',
            onPressed: () => courseProvider.toggleFavorite('MOB01'),
            icon: Icon(
              courseProvider.isFavorite('MOB01')
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ),
      ),
    );
  }
}
