import 'package:flutter_test/flutter_test.dart';
import 'package:videosensei/domain/models/compression_preset.dart';
import 'package:videosensei/domain/models/video_file.dart';
import 'package:videosensei/domain/strategy/preset_strategy.dart';

void main() {
  const strategy = PresetStrategy();

  group('PresetStrategy.buildArgs — Lite preset', () {
    test('uses libx264', () {
      final args = strategy.buildArgs(preset: Presets.lite, meta: null);
      expect(args, containsAll(['-c:v', 'libx264']));
    });

    test('CRF 30', () {
      final args = strategy.buildArgs(preset: Presets.lite, meta: null);
      final crfIdx = args.indexOf('-crf');
      expect(crfIdx, isNot(-1));
      expect(args[crfIdx + 1], '30');
    });

    test('audio is AAC 128k', () {
      final args = strategy.buildArgs(preset: Presets.lite, meta: null);
      expect(args, containsAll(['-c:a', 'aac', '-b:a', '128k']));
    });

    test('includes faststart', () {
      final args = strategy.buildArgs(preset: Presets.lite, meta: null);
      expect(args, containsAll(['-movflags', '+faststart']));
    });

    test('does NOT include hvc1 tag', () {
      final args = strategy.buildArgs(preset: Presets.lite, meta: null);
      expect(args, isNot(contains('hvc1')));
    });
  });

  group('PresetStrategy.buildArgs — Balanced preset', () {
    test('uses libx265', () {
      final args = strategy.buildArgs(preset: Presets.balanced, meta: null);
      expect(args, containsAll(['-c:v', 'libx265']));
    });

    test('CRF 26', () {
      final args = strategy.buildArgs(preset: Presets.balanced, meta: null);
      final crfIdx = args.indexOf('-crf');
      expect(args[crfIdx + 1], '26');
    });

    test('includes hvc1 tag for QuickTime compat', () {
      final args = strategy.buildArgs(preset: Presets.balanced, meta: null);
      expect(args, containsAll(['-tag:v', 'hvc1']));
    });
  });

  group('PresetStrategy.buildArgs — Sensei preset (AV1)', () {
    test('uses libsvtav1', () {
      final args = strategy.buildArgs(preset: Presets.sensei, meta: null);
      expect(args, containsAll(['-c:v', 'libsvtav1']));
    });

    test('uses Opus audio', () {
      final args = strategy.buildArgs(preset: Presets.sensei, meta: null);
      expect(args, containsAll(['-c:a', 'libopus']));
    });

    test('audio bitrate is 96k', () {
      final args = strategy.buildArgs(preset: Presets.sensei, meta: null);
      final idx = args.indexOf('-b:a');
      expect(args[idx + 1], '96k');
    });

    test('does NOT include hvc1 tag', () {
      final args = strategy.buildArgs(preset: Presets.sensei, meta: null);
      expect(args, isNot(contains('hvc1')));
    });
  });

  group('PresetStrategy.buildCommandString', () {
    test('produces valid ffmpeg command string', () {
      final cmd = strategy.buildCommandString(
        inputPath: '/input/video.mp4',
        outputPath: '/output/video_sensei.mp4',
        preset: Presets.balanced,
      );
      expect(cmd, startsWith('ffmpeg'));
      expect(cmd, contains('-i "/input/video.mp4"'));
      expect(cmd, contains('libx265'));
      expect(cmd, contains('"/output/video_sensei.mp4"'));
    });
  });

  group('PresetStrategy.buildArgs — Crystal preset', () {
    test('slow encoder preset for archive quality', () {
      final args = strategy.buildArgs(preset: Presets.crystal, meta: null);
      final presetIdx = args.indexOf('-preset');
      expect(args[presetIdx + 1], 'slow');
    });

    test('CRF 22', () {
      final args = strategy.buildArgs(preset: Presets.crystal, meta: null);
      final crfIdx = args.indexOf('-crf');
      expect(args[crfIdx + 1], '22');
    });

    test('audio bitrate 192k', () {
      final args = strategy.buildArgs(preset: Presets.crystal, meta: null);
      final idx = args.indexOf('-b:a');
      expect(args[idx + 1], '192k');
    });
  });
}
