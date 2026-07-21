import 'package:flutter_test/flutter_test.dart';
import 'package:videosensei/domain/models/compression_preset.dart';
import 'package:videosensei/domain/models/video_file.dart';
import 'package:videosensei/domain/strategy/size_predictor.dart';

void main() {
  const predictor = SizePredictor();

  VideoFile _video({
    int size = 100 * 1024 * 1024, // 100 MB
    int bitrate = 2_000_000,
    double duration = 60,
  }) =>
      VideoFile(
        path: '/test/video.mp4',
        name: 'video',
        size: size,
        metadata: VideoMetadata(
          width: 1920,
          height: 1080,
          fps: 30,
          duration: duration,
          codec: 'h264',
          bitrate: bitrate,
          audioCodec: 'aac',
          audioBitrate: 128_000,
        ),
      );

  group('SizePredictor.predict', () {
    test('returns null when no metadata', () {
      final video = const VideoFile(path: '/v', name: 'v', size: 1000);
      expect(predictor.predict(video: video, preset: Presets.balanced), isNull);
    });

    test('returns null for custom preset', () {
      expect(
        predictor.predict(video: _video(), preset: Presets.custom),
        isNull,
      );
    });

    test('Lite prediction is smaller than original', () {
      final pred = predictor.predict(video: _video(), preset: Presets.lite);
      expect(pred, isNotNull);
      expect(pred!.predictedBytes, lessThan(pred.originalBytes));
    });

    test('Sensei predicts smaller output than Balanced', () {
      final senseiPred =
          predictor.predict(video: _video(), preset: Presets.sensei);
      final balancedPred =
          predictor.predict(video: _video(), preset: Presets.balanced);
      expect(senseiPred!.predictedBytes, lessThan(balancedPred!.predictedBytes));
    });

    test('Crystal predicts larger output than Sensei', () {
      final crystalPred =
          predictor.predict(video: _video(), preset: Presets.crystal);
      final senseiPred =
          predictor.predict(video: _video(), preset: Presets.sensei);
      expect(crystalPred!.predictedBytes,
          greaterThan(senseiPred!.predictedBytes));
    });

    test('predicted bytes are clamped to [5%, 100%] of original', () {
      final pred = predictor.predict(video: _video(), preset: Presets.balanced);
      expect(pred!.predictedBytes,
          greaterThanOrEqualTo((pred.originalBytes * 0.05).round()));
      expect(pred.predictedBytes, lessThanOrEqualTo(pred.originalBytes));
    });

    test('reductionLabel contains minus sign', () {
      final pred = predictor.predict(video: _video(), preset: Presets.balanced);
      expect(pred!.reductionLabel, startsWith('−'));
    });
  });
}
