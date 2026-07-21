import 'package:flutter_test/flutter_test.dart';
import 'package:videosensei/domain/models/compression_preset.dart';
import 'package:videosensei/domain/models/video_file.dart';
import 'package:videosensei/domain/strategy/auto_strategy.dart';

VideoMetadata _meta({
  String codec = 'h264',
  int bitrate = 2_000_000,
  double duration = 120,
  int height = 1080,
}) =>
    VideoMetadata(
      width: (height * 16 / 9).round(),
      height: height,
      fps: 30,
      duration: duration,
      codec: codec,
      bitrate: bitrate,
      audioCodec: 'aac',
      audioBitrate: 128_000,
    );

void main() {
  const strategy = AutoStrategy();

  group('AutoStrategy.recommend', () {
    test('AV1 source → null (do not re-encode)', () {
      expect(strategy.recommend(_meta(codec: 'av1')), isNull);
    });

    test('very low bitrate → null (already tiny)', () {
      expect(strategy.recommend(_meta(bitrate: 300_000)), isNull);
    });

    test('short clip (< 30 s) → Lite', () {
      expect(strategy.recommend(_meta(duration: 20)), PresetKey.lite);
    });

    test('4K content → Balanced', () {
      expect(strategy.recommend(_meta(height: 2160)), PresetKey.balanced);
    });

    test('very high bitrate (> 5 Mbps) → Crystal', () {
      expect(
        strategy.recommend(_meta(bitrate: 6_000_000)),
        PresetKey.crystal,
      );
    });

    test('MPEG-2 source → Lite (max compat)', () {
      expect(strategy.recommend(_meta(codec: 'mpeg2video')), PresetKey.lite);
    });

    test('standard HD H.264 → Balanced (default)', () {
      expect(strategy.recommend(_meta()), PresetKey.balanced);
    });

    test('ProRes source → Crystal (archive quality)', () {
      expect(strategy.recommend(_meta(codec: 'prores')), PresetKey.crystal);
    });
  });

  group('AutoStrategy.explain', () {
    test('returns non-empty explanation for every preset key', () {
      for (final key in PresetKey.values) {
        final explanation = strategy.explain(_meta(), key);
        expect(explanation, isNotEmpty);
      }
    });

    test('null key returns "already optimally compressed" message', () {
      final explanation = strategy.explain(_meta(codec: 'av1'), null);
      expect(explanation.toLowerCase(), contains('already'));
    });
  });
}
