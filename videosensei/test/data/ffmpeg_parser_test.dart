import 'package:flutter_test/flutter_test.dart';
import 'package:videosensei/data/ffmpeg/ffmpeg_parser.dart';

void main() {
  group('FFmpegParser', () {
    late FFmpegParser parser;

    setUp(() => parser = FFmpegParser());

    test('returns null for non-progress lines', () {
      expect(parser.parseLine('Input #0, mov,mp4,m4a ...'), isNull);
      expect(parser.parseLine('Stream #0:0: Video: h264'), isNull);
    });

    test('parses duration from header line', () {
      // Should extract duration but return null (not a progress line)
      final result = parser.parseLine(
        '  Duration: 00:01:30.50, start: 0.000000, bitrate: 2000 kb/s',
      );
      expect(result, isNull); // Duration line itself is not a progress line
    });

    test('parses progress line correctly', () {
      // First feed the duration so the parser knows the total
      parser.parseLine('  Duration: 00:02:00.00, start: 0.000000, bitrate: 2000 kb/s');

      final progress = parser.parseLine(
        'frame=  120 fps= 24 q=26.0 size=    1024kB time=00:00:30.00 bitrate=1678.0kbits/s speed=1.25x',
      );

      expect(progress, isNotNull);
      expect(progress!.percent, closeTo(0.25, 0.01)); // 30s / 120s = 25%
      expect(progress.speed, closeTo(1.25, 0.01));
      expect(progress.currentFrame, '120');
      expect(progress.currentTime, '00:00:30.00');
    });

    test('progress at 100% at end of encode', () {
      parser.parseLine('  Duration: 00:01:00.00, ...');
      final progress = parser.parseLine(
        'frame= 1800 fps= 24 q=26.0 size=   50000kB time=00:01:00.00 bitrate=6666.0kbits/s speed=1.0x',
      );
      expect(progress?.percent, closeTo(1.0, 0.01));
    });

    test('reset clears cached duration', () {
      parser.parseLine('  Duration: 00:02:00.00, ...');
      parser.reset();
      // After reset, duration unknown → progress percent should be 0
      final progress = parser.parseLine(
        'frame=  120 fps= 24 q=26.0 size=    1024kB time=00:00:30.00 bitrate=1678.0kbits/s speed=1.25x',
      );
      expect(progress?.percent, 0.0);
    });
  });
}
