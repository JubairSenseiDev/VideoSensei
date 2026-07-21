/// Base class for all VideoSensei compression errors.
sealed class CompressionError implements Exception {
  final String message;
  const CompressionError(this.message);

  @override
  String toString() => 'CompressionError: $message';
}

/// FFmpeg binary not found or failed to execute.
class FFmpegNotFoundError extends CompressionError {
  const FFmpegNotFoundError() : super(
    'FFmpeg binary not found. Please reinstall VideoSensei.',
  );
}

/// ffprobe failed to read the input file.
class ProbeError extends CompressionError {
  final String path;
  const ProbeError(this.path) : super('Failed to read video metadata: $path');
}

/// The input file format is not supported.
class UnsupportedFormatError extends CompressionError {
  final String extension;
  const UnsupportedFormatError(this.extension) : super(
    'Unsupported format: .$extension',
  );
}

/// Encoding failed mid-way.
class EncodingError extends CompressionError {
  final int exitCode;
  final String stderr;
  const EncodingError({required this.exitCode, required this.stderr})
      : super('FFmpeg exited with code $exitCode');
}

/// Insufficient storage space for the output file.
class InsufficientStorageError extends CompressionError {
  const InsufficientStorageError() : super(
    'Not enough storage space for the output file.',
  );
}

/// The user cancelled the operation.
class UserCancelledError extends CompressionError {
  const UserCancelledError() : super('Compression cancelled by user.');
}
