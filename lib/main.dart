import 'package:flutter/material.dart';

import 'services/course_service.dart';
import 'repositories/course_repository.dart';
import 'services/student_service.dart';

import 'package:provider/provider.dart';

import 'providers/course_provider.dart';
import 'models/course.dart';

const String studentName = 'Putri Ari Laksmi';
const String studentId = '2415051091';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) =>
          CourseProvider(CourseRepository(CourseService()))..loadCourses(),
      child: const MyApp(),
    ),
  );
}

Future<Map<String, dynamic>> loadStudentData() =>
    StudentService().loadStudent();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

// identity card

class IdentityCard extends StatelessWidget {
  const IdentityCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.badge_outlined,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 12),

            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 3),
                  Text('NIM: $studentId'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  int currentIndex = 0;

  final feedbackFormKey = GlobalKey<FormState>();

  String feedbackName = studentName;
  String feedbackNim = studentId;
  String feedbackComment = '';
  String? feedbackResult;

  bool isSubmitting = false;
  bool isNavigating = false;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  int columnsFor(double width) {
    if (width < 600) return 1;
    if (width < 840) return 2;
    return 3;
  }

  NavigationBar _buildNavigationBar() {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.school), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  NavigationRail _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      labelType: NavigationRailLabelType.all,
      groupAlignment: -1.0,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
        NavigationRailDestination(
          icon: Icon(Icons.school),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final orientation = MediaQuery.of(context).orientation;

    final layoutType = size.width < 600
        ? 'Compact'
        : size.width < 840
        ? 'Medium'
        : 'Expanded';

    final pageTitles = ['Course Explorer', 'Courses', 'Profile'];

    return FutureBuilder<Map<String, dynamic>>(
      future: studentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat data: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final data = snapshot.data!;

        final student = data;

        final courses = context.watch<CourseProvider>().courses;

        final completedCount = courses
            .where((course) => course.status == 'done')
            .length;

        final pages = [
          _buildHomePage(
            courses: courses,
            completedCount: completedCount,
            size: size,
            orientation: orientation,
            layoutType: layoutType,
          ),
          _buildCoursesPage(courses: courses),
          _buildProfilePage(student: student),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 840) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(pageTitles[currentIndex]),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                body: SafeArea(child: pages[currentIndex]),
                bottomNavigationBar: _buildNavigationBar(),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: Text(pageTitles[currentIndex]),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildNavigationRail(),

                    const VerticalDivider(width: 1),

                    Expanded(
                      child: SizedBox.expand(child: pages[currentIndex]),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // home

  Widget _buildHomePage({
    required List<Course> courses,
    required int completedCount,
    required Size size,
    required Orientation orientation,
    required String layoutType,
  }) {
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

  // course

  Widget _buildCoursesPage({required List<Course> courses}) {
    final favoriteCount = context.watch<CourseProvider>().favorites.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IdentityCard(),

          const SizedBox(height: 16),

          Text(
            'Daftar Course • Favorite: $favoriteCount',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (context.watch<CourseProvider>().isLoading)
            const Center(child: CircularProgressIndicator())
          else if (context.watch<CourseProvider>().error != null) ...[
            Text(context.watch<CourseProvider>().error!),
            FilledButton(
              onPressed: () => context.read<CourseProvider>().loadCourses(),
              child: const Text('Coba lagi'),
            ),
          ] else
            _buildCourseGrid(courses),
        ],
      ),
    );
  }

  // profile

  Widget _buildProfilePage({required Map<String, dynamic> student}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(student),

          const SizedBox(height: 20),

          _buildScrollableFormDemo(),

          const SizedBox(height: 20),

          _buildFeedbackForm(),
        ],
      ),
    );
  }

  // profile card

  Widget _buildProfileCard(Map<String, dynamic> student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIM: ${student['nim']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 4),

                  Text('Nama: ${student['name']}'),

                  const SizedBox(height: 4),

                  Text(student['semester'] as String),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // summary card

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

  // grid course

  Widget _buildCourseGrid(List<Course> courses) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(constraints.maxWidth);

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
            return _buildCourseCard(courses[index]);
          },
        );
      },
    );
  }

  // course card

  Widget _buildCourseCard(Course course) {
    final statusInfo = _statusInfo(course.status);
    final courseCode = course.code;
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
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => CourseDetailPage(course: course),
              ),
            );
            if (!mounted) return;
            setState(() => isNavigating = false);
            if (result == true) {
              final provider = context.read<CourseProvider>();
              if (!provider.isFavorite(courseCode)) {
                provider.toggleFavorite(courseCode);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${course.title} ditambahkan ke favorite'),
                ),
              );
            }
          },
          child: ListTile(
            leading: Icon(statusInfo.icon, color: statusInfo.color),
            title: Text(
              course.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('$courseCode • ${course.credits} SKS'),
            // watch membaca jumlah pada halaman, Consumer mendengar ikon, read menjalankan aksi.
            trailing: Consumer<CourseProvider>(
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
                    context.read<CourseProvider>().toggleFavorite(courseCode);
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
            ),
          ),
        ),
      ),
    );
  }

  // form profile

  Widget _buildScrollableFormDemo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Form Profil',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Nama',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'NIM',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Program Studi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Semester',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Tentang Saya',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Simpan Profil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // feedback form

  Widget _buildFeedbackForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: feedbackFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Form Feedback',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                '$studentId - $studentName',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: studentName,
                decoration: const InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }

                  return null;
                },
                onSaved: (value) {
                  feedbackName = value!.trim();
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: studentId,
                decoration: const InputDecoration(
                  labelText: 'NIM',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'NIM wajib diisi';
                  }

                  return null;
                },
                onSaved: (value) {
                  feedbackNim = value!.trim();
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Komentar',
                  hintText: 'Masukkan komentar minimal 5 karakter',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Komentar wajib diisi';
                  }

                  if (value.trim().length < 5) {
                    return 'Komentar minimal 5 karakter';
                  }

                  return null;
                },
                onSaved: (value) {
                  feedbackComment = value!.trim();
                },
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!feedbackFormKey.currentState!.validate()) {
                            return;
                          }

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Konfirmasi'),
                                content: const Text('Kirim feedback ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('Kirim'),
                                  ),
                                ],
                              );
                            },
                          );

                          if (confirm != true) {
                            return;
                          }

                          feedbackFormKey.currentState!.save();

                          setState(() {
                            isSubmitting = true;
                          });

                          await Future.delayed(const Duration(seconds: 1));

                          if (!mounted) {
                            return;
                          }

                          setState(() {
                            isSubmitting = false;

                            feedbackResult =
                                'Nama: $feedbackName\n'
                                'NIM: $feedbackNim\n'
                                'Komentar: $feedbackComment';
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feedback berhasil dikirim'),
                            ),
                          );
                        },

                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Kirim Feedback'),
                ),
              ),

              if (feedbackResult != null) ...[
                const SizedBox(height: 20),

                const Text(
                  'Hasil Feedback',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(feedbackResult!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // status course

  _StatusInfo _statusInfo(String status) {
    switch (status) {
      case 'done':
        return const _StatusInfo(
          label: 'Selesai',
          icon: Icons.menu_book_rounded,
          color: Colors.green,
        );

      case 'active':
        return const _StatusInfo(
          label: 'Aktif',
          icon: Icons.menu_book_rounded,
          color: Colors.orange,
        );

      default:
        return const _StatusInfo(
          label: 'Rencana',
          icon: Icons.menu_book_rounded,
          color: Colors.grey,
        );
    }
  }
}

// course detail

class CourseDetailPage extends StatelessWidget {
  final Course course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Course')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IdentityCard(),

            const SizedBox(height: 24),

            Text(
              course.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Text('Kode: ${course.code}'),

            const SizedBox(height: 8),

            Text('SKS: ${course.credits}'),

            const SizedBox(height: 8),

            Text('Status: ${course.status}'),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                icon: const Icon(Icons.favorite),
                label: const Text('Pilih / Favorite'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// responsive layout

class ResponsiveLayoutDemo extends StatelessWidget {
  const ResponsiveLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          return const CompactLayout();
        } else if (constraints.maxWidth < 840) {
          return const MediumLayout();
        } else {
          return const ExpandedLayout();
        }
      },
    );
  }
}

class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.phone_android, size: 36),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compact Layout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text('Kategori Layout: Compact'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.tablet_android, size: 36),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medium Layout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text('Kategori Layout: Medium'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.desktop_windows, size: 40),

            SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expanded Layout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text('Kategori Layout: Expanded'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// expanded dan warp

class FlexibleLayoutDemo extends StatelessWidget {
  const FlexibleLayoutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final skills = [
      'Flutter',
      'Dart',
      'Git',
      'UI Layout',
      'Navigation',
      'Responsive',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flexible Layout',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    color: Colors.blue.shade100,
                    child: const Text(
                      'Panel A\nFlex 2',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: 1,
                  child: Container(
                    height: 80,
                    alignment: Alignment.center,
                    color: Colors.orange.shade100,
                    child: const Text(
                      'Panel B\nFlex 1',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Skills dengan Wrap',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map((skill) => Chip(label: Text(skill)))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// status info

class _StatusInfo {
  const _StatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;
}

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
