import 'package:flutter/material.dart';

class ResponsiveLayoutDemo extends StatelessWidget {
  const ResponsiveLayoutDemo({super.key});

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
  const CompactLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.phone_android, size: 36),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compact Layout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text('Kategori Layout: Compact'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.tablet_android, size: 36),

            SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medium Layout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text('Kategori Layout: Medium'),
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
  const ExpandedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: const [
            Icon(Icons.desktop_windows, size: 40),

            SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expanded Layout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 4),

                  Text('Kategori Layout: Expanded'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
