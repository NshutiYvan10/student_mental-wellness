class MoodEntry {
  final DateTime date;
  final int mood; // 1-5
  final String note;

  MoodEntry({required this.date, required this.mood, this.note = ''});

  Map<String, dynamic> toMap() => {
        'date': date.toIso8601String(),
        'mood': mood,
        'note': note,
      };

  factory MoodEntry.fromMap(Map<String, dynamic> map) => MoodEntry(
        date: DateTime.parse(map['date'] as String),
        mood: map['mood'] as int,
        note: (map['note'] as String?) ?? '',
      );
}



