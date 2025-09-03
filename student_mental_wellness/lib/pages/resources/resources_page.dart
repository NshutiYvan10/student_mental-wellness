import 'package:flutter/material.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> items = const [
      {'title': 'Mindfulness Basics', 'type': 'Article', 'min': 5},
      {'title': 'Breathing Techniques', 'type': 'Video', 'min': 7},
      {'title': 'Coping with Anxiety', 'type': 'Guide', 'min': 10},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (_, i) {
          final r = items[i];
          return Material(
            elevation: 4,
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              leading: CircleAvatar(child: Text((r['type'] as String)[0])),
              title: Text(r['title'] as String),
              subtitle: Text('${r['type']} • ${r['min']} min'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}


