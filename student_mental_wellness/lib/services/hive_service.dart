import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String moodsBox = 'moods_box';
  static const String journalBox = 'journal_box';
  static const String settingsBox = 'settings_box';
  // Settings keys
  static const String keyProfileName = 'profile_name';
  static const String keyProfileSchool = 'profile_school';
  static const String keyProfileAvatarPath = 'profile_avatar_path';
  static const String keyMeditationStreak = 'meditation_streak';
  static const String keyMeditationLastDate = 'meditation_last_date';

  static Future<void> initialize() async {
    await Hive.openBox(moodsBox);
    await Hive.openBox(journalBox);
    await Hive.openBox(settingsBox);
  }
}


