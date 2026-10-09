import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_1/main.dart';

void main() {
  testWidgets('Local state hanya membuka panel demo', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: LocalStateDemo())));
    expect(find.text('Tampilkan Detail'), findsOneWidget);
    await tester.tap(find.text('Tampilkan Detail'));
    await tester.pump();
    expect(find.text('Sembunyikan Detail'), findsOneWidget);
    await tester.tap(find.text('Sembunyikan Detail'));
    await tester.pump();
    expect(find.text('Tampilkan Detail'), findsOneWidget);
  });
}
