# Course Explorer v2

Putri Ari Laksmi — NIM 2415051091. Project Flutter Pertemuan 5 yang dilanjutkan dengan state management dan arsitektur Pertemuan 6.

## Menjalankan aplikasi

```bash
flutter pub get
flutter run -d chrome
```

Navigasi terdiri dari Home, Courses, Favorites, dan Profile. Favorite disimpan dalam memori selama aplikasi berjalan. Profile mempertahankan form, validasi, dialog konfirmasi, loading, hasil feedback, dan SnackBar. Tekan lama card course untuk informasi singkat; tap card untuk Detail Course.

Breakpoint memakai lebar viewport: compact `<600` (grid satu kolom), medium `600–839` (dua kolom), expanded `>=840` (tiga kolom). Compact/medium memakai NavigationBar, expanded memakai NavigationRail. Lebar viewport dipakai untuk grid sehingga rail tidak mengubah kategori expanded.

## Arsitektur Pertemuan 6

### models/
Representasi data domain seperti Course. Student identity menyimpan nama dan NIM yang tetap.

### services/
Akses teknis ke data source seperti JSON asset. CourseService dan StudentService membaca `assets/data/student_data.json`; parsing hanya berada pada layer ini dan factory model.

### repositories/
Abstraksi akses data untuk Provider. CourseRepository dan StudentRepository meneruskan permintaan ke service, tanpa widget atau BuildContext.

### providers/
Application/shared state dan action. CourseProvider mengelola initial/loading/success/error, retry, serta favorite. StudentProvider mengelola data profil. Provider tidak menyimpan BuildContext dan hanya menerima repository.

### screens/
Komposisi halaman dan presentation flow. Dashboard mengatur navigasi; Home, Courses, Favorites, Profile, dan Detail membaca Provider. UI tidak memuat atau mem-parsing JSON. Form feedback adalah local state pada Profile.

### widgets/
Komponen UI reusable: IdentityCard, CourseCard, CourseGrid, responsive/flexible layout, dan demo local state. Demo latihan memiliki state terisolasi sesuai tujuan tahap; favorite aplikasi utama memakai satu CourseProvider root.

### debug/
Debug State Lab terisolasi untuk empat kasus debugging. Tombol masuk hanya muncul saat `kDebugMode`. Repository gagal khusus lab tidak dipakai oleh alur produksi. Lihat [catatan debugging](docs/pertemuan6_debug_notes.md).

### Arah dependency

```text
Screen / Widget
       |
       v
CourseProvider                  StudentProvider
       |                              |
       v                              v
CourseRepository                StudentRepository
       |                              |
       v                              v
CourseService                   StudentService
       |                              |
       +-----------> JSON asset <-----+

Course adalah model data yang dipakai antar-layer.
main.dart menyusun dependency dan theme aplikasi.
```

Load dilakukan sekali ketika Provider root dibuat, bukan pada setiap build. Permintaan bersamaan ditolak ketika loading. Hasil async setelah dispose tidak memberi notifikasi. Koleksi course dan favorite yang diekspos bersifat unmodifiable. Error UI menyediakan retry tanpa mengubah asset produksi.

## Struktur final

```text
lib/
  main.dart
  models/        course.dart, student_identity.dart
  services/      course_service.dart, student_service.dart
  repositories/  course_repository.dart, student_repository.dart
  providers/     course_provider.dart, student_provider.dart
  screens/       dashboard_page.dart, home_page.dart, courses_page.dart,
                 course_detail_page.dart, favorites_page.dart, profile_page.dart
  widgets/       identity_card.dart, course_card.dart, course_grid.dart,
                 course_status.dart, responsive_layout_demo.dart,
                 flexible_layout_demo.dart, state_demos.dart
  debug/         state_debug_lab.dart
assets/data/student_data.json
docs/
  pertemuan6_screenshot_map.md
  pertemuan6_state_notes.md
  pertemuan6_debug_notes.md
  pertemuan6_architecture_audit.md
test/            unit, asset, widget, dan regresi UI
```
