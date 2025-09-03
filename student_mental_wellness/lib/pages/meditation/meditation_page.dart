import 'package:flutter/material.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';
import '../../widgets/breathing_animation.dart';
import '../../services/hive_service.dart';

class MeditationPage extends StatefulWidget {
  const MeditationPage({super.key});

  @override
  State<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends State<MeditationPage> {
  int _streak = 0;
  final List<int> _durations = [60, 180, 300];
  int _selected = 180;
  int _remaining = 0;
  bool _running = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final box = Hive.box(HiveService.settingsBox);
    _streak = (box.get(HiveService.keyMeditationStreak) as int?) ?? 0;
    // Timer created on start
  }

  Future<void> _completeSession() async {
    final box = Hive.box(HiveService.settingsBox);
    final last = box.get(HiveService.keyMeditationLastDate) as String?;
    final today = DateTime.now();
    bool increment = true;
    if (last != null) {
      final lastDt = DateTime.parse(last);
      final diff = today.difference(DateTime(lastDt.year, lastDt.month, lastDt.day)).inDays;
      if (diff == 0) increment = false; // same day, don’t increment
      if (diff > 1) _streak = 0; // broken streak
    }
    if (increment) _streak += 1;
    await box.put(HiveService.keyMeditationStreak, _streak);
    await box.put(HiveService.keyMeditationLastDate, today.toIso8601String());
    if (!mounted) return;
    setState(() {});
    // Optional feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session completed!')));
    }
  }

  void _start() {
    if (_running) return;
    setState(() {
      _remaining = _selected;
      _running = true;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_running) return;
      final newRemaining = (_remaining - 1).clamp(0, _selected);
      if (newRemaining != _remaining) {
        setState(() => _remaining = newRemaining);
      }
      if (_remaining == 0) {
        _running = false;
        _timer?.cancel();
        _completeSession();
      }
    });
  }

  void _stop() {
    setState(() => _running = false);
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meditation')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const BreathingAnimation(),
            const SizedBox(height: 20),
            Text('Breathe in... Breathe out...',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Daily streak: $_streak day${_streak == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: _durations.map((s) {
                final selected = s == _selected;
                return ChoiceChip(
                  label: Text('${(s / 60).round()} min'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selected = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(_running ? _format(_remaining) : _format(_selected),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _running ? null : _start,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _running ? _stop : null,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text('Stop'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  String _format(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }
}


