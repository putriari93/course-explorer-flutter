import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Putri Ari Laksmi';
const String studentId = '2415051091';

void main() {
  runApp(const MyApp());
}

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learning Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final layoutType = size.width < 600 ? 'Compact' : 'Wide';

    final pageTitles = [
      'Learning Dashboard',
      'Courses',
      'Profile',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[currentIndex]),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),

      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final data = snapshot.data!;

            final student =
                data['student'] as Map<String, dynamic>;

            final courses = (data['courses'] as List<dynamic>)
                .cast<Map<String, dynamic>>();

            final completedCount = courses
                .where(
                  (course) => course['status'] == 'done',
                )
                .length;

            final pages = [
              _buildHomePage(
                student: student,
                courses: courses,
                completedCount: completedCount,
                size: size,
                orientation: orientation,
                layoutType: layoutType,
              ),

              _buildCoursesPage(
                courses: courses,
              ),

              _buildProfilePage(
                student: student,
              ),
            ];

            return pages[currentIndex];
          },
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // home

  Widget _buildHomePage({
    required Map<String, dynamic> student,
    required List<Map<String, dynamic>> courses,
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
          // tahap 2 - MediaQuery
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '$studentId - $studentName',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Width: ${size.width.toStringAsFixed(0)}',
                  ),
                  Text(
                    'Height: ${size.height.toStringAsFixed(0)}',
                  ),
                  Text(
                    'Orientation: $orientation',
                  ),
                  Text(
                    'Layout: $layoutType',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // tahap 3
          const ResponsiveLayoutDemo(),

          const SizedBox(height: 12),

          // tahap 4
          const FlexibleLayoutDemo(),

          const SizedBox(height: 12),

          // informasi mahasiswa
          _buildProfileCard(student),

          const SizedBox(height: 12),

          // ringkasan
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

  Widget _buildCoursesPage({
    required List<Map<String, dynamic>> courses,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '$studentId - $studentName',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Daftar Course',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 12),

          _buildCourseGrid(courses),
        ],
      ),
    );
  }

  // profile

  Widget _buildProfilePage({
    required Map<String, dynamic> student,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProfileCard(student),

          const SizedBox(height: 20),

          _buildScrollableFormDemo(),
        ],
      ),
    );
  }

  // profile card

  Widget _buildProfileCard(
    Map<String, dynamic> student,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor:
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer,
              child: Icon(
                Icons.person,
                color: Theme.of(context)
                    .colorScheme
                    .onPrimaryContainer,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'NIM: ${student['nim']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nama: ${student['name']}',
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student['semester'] as String,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // sumarry card

  Widget _buildSummaryCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
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

              Text(
                label,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // grid course

  Widget _buildCourseGrid(
    List<Map<String, dynamic>> courses,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),

          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount:
                columnsFor(constraints.maxWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.8,
          ),

          itemCount: courses.length,

          itemBuilder: (context, index) {
            return _buildCourseCard(
              courses[index],
            );
          },
        );
      },
    );
  }

  // course card

  Widget _buildCourseCard(
    Map<String, dynamic> course,
  ) {
    final status = course['status'] as String;
    final statusInfo = _statusInfo(status);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: () async {
          final result =
              await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(
                course: course,
              ),
            ),
          );

          if (result == true && mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  '${course['title']} ditambahkan ke favorite',
                ),
              ),
            );
          }
        },

        leading: Icon(
          statusInfo.icon,
          color: statusInfo.color,
        ),

        title: Text(
          course['title'] as String,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Text(
          '${course['code']} • ${course['credits']} SKS',
        ),

        trailing: Text(
          statusInfo.label,
          style: TextStyle(
            color: statusInfo.color,
            fontWeight: FontWeight.bold,
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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Form Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
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
                child: const Text(
                  'Simpan Profil',
                ),
              ),
            ),
          ],
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
  final Map<String, dynamic> course;

  const CourseDetailPage({
    super.key,
    required this.course,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Course'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              course['title'] as String,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'Kode: ${course['code']}',
            ),

            const SizedBox(height: 8),

            Text(
              'SKS: ${course['credits']}',
            ),

            const SizedBox(height: 8),

            Text(
              'Status: ${course['status']}',
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                ),
                label: const Text(
                  'Pilih / Favorite',
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// layout builder

class ResponsiveLayoutDemo extends StatelessWidget {
  const ResponsiveLayoutDemo({
    super.key,
  });

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
  const CompactLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: const [
            Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Kategori Layout: Compact',
            ),
            SizedBox(height: 8),
            Icon(
              Icons.phone_android,
              size: 36,
            ),
          ],
        ),
      ),
    );
  }
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(
              Icons.tablet_android,
              size: 36,
            ),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '$studentId - $studentName',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kategori Layout: Medium',
                  ),
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
  const ExpandedLayout({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(
              Icons.desktop_windows,
              size: 40,
            ),

            SizedBox(width: 20),

            Expanded(
              child: Text(
                '$studentId - $studentName\n'
                'Kategori Layout: Expanded',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// expanded and warp

class FlexibleLayoutDemo extends StatelessWidget {
  const FlexibleLayoutDemo({
    super.key,
  });

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
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              '$studentId - $studentName',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 80,
                    alignment:
                        Alignment.center,
                    color:
                        Colors.blue.shade100,
                    child: const Text(
                      'Panel A\nFlex 2',
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  flex: 1,
                  child: Container(
                    height: 80,
                    alignment:
                        Alignment.center,
                    color:
                        Colors.orange.shade100,
                    child: const Text(
                      'Panel B\nFlex 1',
                      textAlign:
                          TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Skills dengan Wrap',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                    ),
                  )
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