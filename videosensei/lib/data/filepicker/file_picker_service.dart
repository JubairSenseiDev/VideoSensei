import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../core/constants/app_constants.dart';
import '../../core/extensions/string_extensions.dart';
import '../../domain/models/video_file.dart';
import '../../domain/exceptions/compression_error.dart';

/// Wraps [FilePicker] with VideoSensei-specific filtering.
class FilePickerService {
  const FilePickerService();

  /// Opens the native file picker and returns a [VideoFile], or `null`
  /// if the user cancelled.
  Future<VideoFile?> pickSingleVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedExtensions,
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    final path = file.path;
    if (path == null) return null;

    return _toVideoFile(path);
  }

  /// Opens the native file picker and returns multiple [VideoFile] objects.
  Future<List<VideoFile>> pickMultipleVideos() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedExtensions,
      allowMultiple: true,
    );

    if (result == null || result.files.isEmpty) return [];

    final videos = <VideoFile>[];
    for (final file in result.files) {
      final path = file.path;
      if (path == null) continue;
      try {
        videos.add(await _toVideoFile(path));
      } catch (_) {
        // Skip unreadable files
      }
    }
    return videos;
  }

  VideoFile _toVideoFile(String path) {
    final ext = path.fileExtension;
    if (!AppConstants.supportedExtensions.contains(ext)) {
      throw UnsupportedFormatError(ext);
    }

    final file = File(path);
    if (!file.existsSync()) throw ProbeError(path);

    return VideoFile(
      path: path,
      name: path.fileBaseName,
      size: file.lengthSync(),
    );
  }

  /// Builds the output path for a given input path and optional output directory.
  String buildOutputPath(String inputPath, {String? outputDir}) {
    final baseName = inputPath.fileBaseName;
    final dir = outputDir ?? inputPath.dirPath;
    return p.join(dir, '$baseName${AppConstants.outputSuffix}${AppConstants.outputExtension}');
  }

  /// Opens a folder picker and returns the chosen directory path, or null.
  Future<String?> pickOutputDirectory() async {
    return FilePicker.platform.getDirectoryPath();
  }
}
