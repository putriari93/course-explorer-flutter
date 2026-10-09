import 'package:flutter/material.dart';

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
