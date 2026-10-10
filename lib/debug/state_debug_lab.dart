import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../repositories/course_repository.dart';
import '../services/course_service.dart';
import '../widgets/identity_card.dart';

class StateDebugLab extends StatelessWidget {
  const StateDebugLab({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Debug State Lab')),
    body: Column(
      children: [
        const Padding(padding: EdgeInsets.all(16), child: IdentityCard()),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: const [
              _NotifyDemo(),
              _ProviderScopeDemo(),
              _ServiceErrorDemo(),
              _AsyncLifecycleDemo(),
            ],
          ),
        ),
      ],
    ),
  );
}

class DebugNotifier extends ChangeNotifier {
  int value = 0;
  void incrementSilently() {
    value++;
  }

  void incrementAndNotify() {
    value++;
    notifyListeners();
  }
}

class _NotifyDemo extends StatefulWidget {
  const _NotifyDemo();
  @override
  State<_NotifyDemo> createState() => _NotifyDemoState();
}

class _NotifyDemoState extends State<_NotifyDemo> {
  final notifier = DebugNotifier();
  @override
  void dispose() {
    notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Case A ? notifyListeners',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text(
            'Tanpa notify, nilai berubah tetapi tampilan listener tetap. Notify berikutnya menampilkan seluruh perubahan.',
          ),
          ListenableBuilder(
            listenable: notifier,
            builder: (context, child) =>
                Text('Nilai listener: ${notifier.value}'),
          ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: notifier.incrementSilently,
                child: const Text('Tanpa notify'),
              ),
              TextButton(
                onPressed: notifier.incrementAndNotify,
                child: const Text('Dengan notify'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class DebugScopeValue {
  final String message = 'Context anak berhasil membaca Provider';
}

class _ProviderScopeDemo extends StatelessWidget {
  const _ProviderScopeDemo();
  @override
  Widget build(BuildContext context) {
    String explanation;
    try {
      context
          .read<
            DebugScopeValue
          >(); 
      explanation = 'Provider ditemukan';
    } on ProviderNotFoundException {
      explanation = 'ProviderNotFoundException ditangkap: context berada di atas Provider.';
    }
    return Provider(
      create: (_) => DebugScopeValue(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Case B ? posisi context',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(explanation),
              Builder(
                builder: (innerContext) =>
                    Text(innerContext.read<DebugScopeValue>().message),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DebugFailingRepository extends CourseRepository {
  DebugFailingRepository() : super(CourseService());
  @override
  Future<List<Course>> getCourses() async =>
      throw StateError('Simulasi service error khusus lab');
}

class _ServiceErrorDemo extends StatefulWidget {
  const _ServiceErrorDemo();
  @override
  State<_ServiceErrorDemo> createState() => _ServiceErrorDemoState();
}

class _ServiceErrorDemoState extends State<_ServiceErrorDemo> {
  late final CourseProvider debugProvider;
  @override
  void initState() {
    super.initState();
    debugProvider = CourseProvider(DebugFailingRepository())..loadCourses();
  }

  @override
  void dispose() {
    debugProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: debugProvider,
    builder: (context, child) => Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Case C ? service error',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (debugProvider.isLoading)
              const CircularProgressIndicator()
            else
              Text(debugProvider.error ?? 'Belum memuat'),
            TextButton(
              onPressed: debugProvider.isLoading
                  ? null
                  : debugProvider.loadCourses,
              child: const Text('Coba service gagal'),
            ),
            const Text(
              'Repository lab terpisah; data course aplikasi tetap berhasil dimuat.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _AsyncLifecycleDemo extends StatefulWidget {
  const _AsyncLifecycleDemo();
  @override
  State<_AsyncLifecycleDemo> createState() => _AsyncLifecycleDemoState();
}

class _AsyncLifecycleDemoState extends State<_AsyncLifecycleDemo> {
  bool pending = false;
  String result = 'Belum dimulai';
  Future<void> start() async {
    setState(() {
      pending = true;
      result = 'Menunggu async; boleh kembali dari lab';
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      pending = false;
      result = 'Async selesai dengan aman';
    });
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Case D ? async lifecycle',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(result),
          FilledButton(
            onPressed: pending ? null : start,
            child: const Text('Mulai async'),
          ),
          const Text(
            'Pemeriksaan mounted mencegah setState setelah halaman ditutup.',
          ),
        ],
      ),
    ),
  );
}
