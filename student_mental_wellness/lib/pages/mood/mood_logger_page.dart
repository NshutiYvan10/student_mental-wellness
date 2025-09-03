import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/hive_service.dart';

class MoodLoggerPage extends StatefulWidget {
  const MoodLoggerPage({super.key});

  @override
  State<MoodLoggerPage> createState() => _MoodLoggerPageState();
}

class _MoodLoggerPageState extends State<MoodLoggerPage> {
  int _selected = 3; // 1..5
  final _noteCtrl = TextEditingController();

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final box = Hive.box(HiveService.moodsBox);
    await box.add({
      'date': DateTime.now().toIso8601String(),
      'mood': _selected,
      'note': _noteCtrl.text,
    });
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Mood')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('How are you feeling?', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _EmojiWheel(
              selected: _selected,
              onSelect: (v) => setState(() {
                _selected = v;
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Add a note (optional)',
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.check),
                    label: const Text('Save'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/mood/list'),
                    icon: const Icon(Icons.history),
                    label: const Text('History'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _EmojiWheel extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;
  const _EmojiWheel({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final emojis = ['', '😢', '🙁', '😐', '🙂', '😀'];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 10,
      children: [
        for (int i = 1; i <= 5; i++)
          InkWell(
            onTap: () => onSelect(i),
            borderRadius: BorderRadius.circular(18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: i == selected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: i == selected ? Theme.of(context).colorScheme.primary : Colors.grey.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  if (i == selected)
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                ],
              ),
              child: Text(emojis[i], style: const TextStyle(fontSize: 28)),
            ),
          )
      ],
    );
  }
}


