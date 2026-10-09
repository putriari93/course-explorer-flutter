import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/student_provider.dart';
import '../models/student_identity.dart';
import '../widgets/identity_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final feedbackFormKey = GlobalKey<FormState>();

  String feedbackName = studentName;
  String feedbackNim = studentId;
  String feedbackComment = '';
  String? feedbackResult;

  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentProvider>();
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!),
            FilledButton(
              onPressed: () => context.read<StudentProvider>().loadStudent(),
              child: const Text('Coba lagi'),
            ),
          ],
        ),
      );
    }
    return _buildProfilePage(student: provider.student);
  }

  Widget _buildProfilePage({required Map<String, dynamic> student}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const IdentityCard(),
          const SizedBox(height: 12),
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

                          if (!mounted || confirm != true) {
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
}
