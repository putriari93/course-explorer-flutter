import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_1/providers/course_provider.dart';

void main() {
  test('Favorite memberi notifikasi dan koleksi tidak bisa diubah dari luar', () {
    final provider = CourseProvider();
    addTearDown(provider.dispose);
    var notifications = 0;
    provider.addListener(() => notifications++);
    provider.toggleFavorite('MOB01');
    expect(provider.isFavorite('MOB01'), isTrue);
    expect(notifications, 1);
    expect(() => provider.favorites.add('MOB02'), throwsUnsupportedError);
    provider.toggleFavorite('MOB01');
    expect(provider.favorites, isEmpty);
    expect(notifications, 2);
  });
}
