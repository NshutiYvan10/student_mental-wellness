import 'dart:typed_data';

import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart' as tfl;

class MlService {
  tfl.Interpreter? _interpreter;

  Future<void> initialize() async {
    try {
      // Try ML Kit model named 'sentiment' first (remote or cached)
      final model = await FirebaseModelDownloader.instance.getModel(
        'sentiment',
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );
      final file = model.file;
      if (await file.exists()) {
        _interpreter = tfl.Interpreter.fromFile(file);
        return;
      }
      // Fallback to bundled asset
      _interpreter = await tfl.Interpreter.fromAsset('models/sentiment.tflite');
    } catch (_) {
      _interpreter = null; // Fallback to heuristic
    }
  }

  // Returns sentiment score in [-1, 1]
  Future<double> analyzeSentiment(String text) async {
    if (text.trim().isEmpty) return 0;
    if (_interpreter == null) {
      // Simple heuristic fallback
      final lower = text.toLowerCase();
      int score = 0;
      for (final w in ['happy', 'great', 'good', 'calm', 'love']) {
        if (lower.contains(w)) score++;
      }
      for (final w in ['sad', 'bad', 'anxious', 'angry', 'stress']) {
        if (lower.contains(w)) score--;
      }
      return score.clamp(-3, 3) / 3.0;
    }

    // Minimal example assuming model takes a single float length input (placeholder pipeline)
    // Real models require tokenization; integrate a matching preprocessor with the model.
    try {
      final input = Uint8List.fromList([text.length.clamp(0, 255)]);
      final output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter!.run(input, output);
      final raw = (output[0][0] as num).toDouble();
      // Map [0,1] -> [-1,1] if needed
      return (raw * 2) - 1;
    } catch (_) {
      // On any error, fallback
      final lower = text.toLowerCase();
      int score = 0;
      for (final w in ['happy', 'great', 'good', 'calm', 'love']) {
        if (lower.contains(w)) score++;
      }
      for (final w in ['sad', 'bad', 'anxious', 'angry', 'stress']) {
        if (lower.contains(w)) score--;
      }
      return score.clamp(-3, 3) / 3.0;
    }
  }
}


