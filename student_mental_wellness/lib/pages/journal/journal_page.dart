import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../services/hive_service.dart';
import '../../services/ml_service.dart';
import '../../widgets/gradient_card.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _ctrl = TextEditingController();
  final _ml = MlService();
  bool _saving = false;
  final _prompts = const [
    'What went well today and why?',
    'What is one thing you can let go of?',
    'Who supported you recently and how?',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_ctrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final sentiment = await _ml.analyzeSentiment(_ctrl.text);
    final id = const Uuid().v4();
    final box = Hive.box(HiveService.journalBox);
    await box.add({
      'id': id,
      'createdAt': DateTime.now().toIso8601String(),
      'text': _ctrl.text,
      'sentiment': sentiment,
    });
    _ctrl.clear();
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box(HiveService.journalBox);
    final entries = box.values.toList().cast<Map>();
    entries.sort((a, b) => (DateTime.parse(b['createdAt'] as String))
        .compareTo(DateTime.parse(a['createdAt'] as String)));

    return Scaffold(
      appBar: AppBar(title: const Text('Journal')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Write your thoughts...'
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator()) : const Text('Save'),
                )
              ],
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => ActionChip(
                label: Text(_prompts[i]),
                onPressed: () => _ctrl.text = _prompts[i],
              ),
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _prompts.length,
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final e = entries[index];
                final sentiment = (e['sentiment'] as num).toDouble();
                final color = sentiment > 0.2
                    ? const [Color(0xFF7C6CF3), Color(0xFF5BA6F1)]
                    : (sentiment < -0.2
                        ? const [Color(0xFFFF9A9E), Color(0xFFFAD0C4)]
                        : const [Color(0xFFFDFBFB), Color(0xFFEBEDEE)]);
                return GradientCard(
                  colors: color,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text((e['createdAt'] as String).replaceFirst('T', ' ').split('.')[0],
                          style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Text(e['text'] as String),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _SentimentBadge(score: sentiment),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class _SentimentBadge extends StatelessWidget {
  final double score; // -1..1
  const _SentimentBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final label = score > 0.2 ? 'Positive' : (score < -0.2 ? 'Negative' : 'Neutral');
    final color = score > 0.2
        ? Colors.green
        : (score < -0.2 ? Colors.red : Colors.amber);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(children: [
        Icon(Icons.insights, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}


