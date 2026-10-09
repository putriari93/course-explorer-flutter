import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_1/debug/state_debug_lab.dart';

void main() {
  testWidgets(
    'Lab membandingkan notify, context dan service gagal dengan aman',
    (tester) async {
      tester.view.physicalSize = const Size(375, 667);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: StateDebugLab()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tanpa notify'));
      await tester.pump();
      expect(find.text('Nilai listener: 0'), findsOneWidget);
      await tester.tap(find.text('Dengan notify'));
      await tester.pump();
      expect(find.text('Nilai listener: 2'), findsOneWidget);
      expect(
        find.textContaining('ProviderNotFoundException ditangkap'),
        findsOneWidget,
      );
      expect(
        find.text('Context anak berhasil membaca Provider'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('Coba service gagal'), 200);
      await tester.pumpAndSettle();
      expect(
        find.text('Gagal memuat course. Silakan coba lagi.'),
        findsOneWidget,
      );
      expect(find.text('Putri Ari Laksmi').hitTestable(), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Mulai async'), 200);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mulai async'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Async selesai dengan aman'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('Menutup lab sebelum async selesai aman', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => const StateDebugLab()),
              ),
              child: const Text('Buka lab'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Buka lab'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Mulai async'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mulai async'));
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Buka lab'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
