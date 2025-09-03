import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/hive_service.dart';
import '../../widgets/gradient_card.dart';

class MoodListPage extends StatelessWidget {
  const MoodListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(HiveService.moodsBox);
    final entries = box.values.toList().cast<Map>();
    entries.sort((a, b) => (DateTime.parse(b['date'] as String))
        .compareTo(DateTime.parse(a['date'] as String)));

    return Scaffold(
      appBar: AppBar(title: const Text('Mood History')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final e = entries[index];
          final mood = e['mood'] as int;
          final note = (e['note'] as String?) ?? '';
          final date = DateTime.parse(e['date'] as String);
          final colors = [
            [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
            [const Color(0xFFFF9A9E), const Color(0xFFFAD0C4)],
            [const Color(0xFFFDFBFB), const Color(0xFFEBEDEE)],
            [const Color(0xFFA1C4FD), const Color(0xFFC2E9FB)],
            [const Color(0xFF96FBC4), const Color(0xFFF9F586)],
          ][mood - 1];
          return GradientCard(
            colors: colors,
            child: Row(
              children: [
                Text(_emojiForMood(mood), style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${date.toLocal()}'.split('.')[0],
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      if (note.isNotEmpty)
                        Text(note, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/mood/logger'),
        label: const Text('Log Mood'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  String _emojiForMood(int mood) => const ['','😢','🙁','😐','🙂','😀'][mood];
}


