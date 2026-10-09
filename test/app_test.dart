import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_1/widgets/course_card.dart';

import 'support/app_fixture.dart';

void main() {
  for (final size in [const Size(375, 667), const Size(1000, 800)]) {
    testWidgets('Navigasi, grid dan detail pada $size', (tester) async {
      final provider = await pumpFixture(tester, size);
      expect(find.text('Putri Ari Laksmi'), findsOneWidget);
      expect(
        find.byType(size.width < 840 ? NavigationBar : NavigationRail),
        findsOneWidget,
      );
      await selectPage(tester, 'Courses');
      final grid = tester.widget<GridView>(find.byType(GridView));
      expect(
        (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
            .crossAxisCount,
        size.width < 600
            ? 1
            : size.width < 840
            ? 2
            : 3,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(CourseCard).first,
          matching: find.byTooltip('Tambahkan ke favorite'),
        ),
      );
      await tester.pumpAndSettle();
      expect(provider.isFavorite('MOB01'), isTrue);
      await tester.tap(find.text('Git & GitHub'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Course'), findsOneWidget);
      expect(find.text('Kode: MOB01'), findsOneWidget);
      expect(find.text('NIM: 2415051091'), findsOneWidget);
      await tester.tap(find.text('Kembali'));
      await tester.pumpAndSettle();
      await selectPage(tester, 'Profile');
      expect(find.text('Semester 5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('Feedback memvalidasi, mengonfirmasi dan menampilkan hasil', (
    tester,
  ) async {
    await pumpFixture(tester, const Size(375, 667));
    await selectPage(tester, 'Profile');
    await tester.ensureVisible(find.text('Kirim Feedback'));
    await tester.tap(find.text('Kirim Feedback'));
    await tester.pumpAndSettle();
    expect(find.text('Komentar wajib diisi'), findsOneWidget);
    await tester.enterText(
      find.byType(TextFormField).at(2),
      'Materi mudah dipahami',
    );
    await tester.ensureVisible(find.text('Kirim Feedback'));
    await tester.tap(find.text('Kirim Feedback'));
    await tester.pumpAndSettle();
    expect(find.text('Kirim feedback ini?'), findsOneWidget);
    await tester.tap(find.text('Kirim'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Feedback berhasil dikirim'), findsOneWidget);
    expect(
      find.textContaining('Komentar: Materi mudah dipahami'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
