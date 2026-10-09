import 'package:flutter_test/flutter_test.dart';
import 'package:latihan_1/services/course_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Asset menghasilkan minimal lima Course dengan kode unik', () async {
    final courses = await CourseService().loadCourses();
    expect(courses.length, greaterThanOrEqualTo(5));
    expect(courses.map((course) => course.code).toSet().length, courses.length);
    expect(courses.first.title, 'Git & GitHub');
    expect(courses.every((course) => course.credits > 0), isTrue);
  });
}
