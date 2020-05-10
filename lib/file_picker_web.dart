// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:async';

import 'package:file_picker/file_picker.dart';

abstract class FilePickerInterface {
  FilePickerInterface._();

  static Future<File> getFile({FileType type = FileType.any, List<String> allowedExtensions}) async {
    List<File> files = await _handleGetFiles(type, false, allowedExtensions);
    return files?.first;
  }

  static Future<List<File>> getMultiFile({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      await _handleGetFiles(type, true, allowedExtensions);

  static Future<String> getFilePath({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      throw UnimplementedError('Unsupported on Flutter Web');

  static Future<Map<String, String>> getMultiFilePath({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      throw UnimplementedError('Unsupported on Flutter Web');

  static Future<bool> clearTemporaryFiles() async => throw UnimplementedError('Unsupported on Flutter Web');

  static Future<List<File>> _handleGetFiles(FileType type, bool allowMultiple, List<String> allowedExtensions) async {
    final Completer<List<File>> pickedFiles = Completer<List<File>>();
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.multiple = allowMultiple;
    uploadInput.accept = _fileType(type, allowedExtensions);
    uploadInput.click();
    uploadInput.onChange.listen((event) => pickedFiles.complete(uploadInput.files));
    return await pickedFiles.future;
  }

  static String _fileType(FileType type, List<String> allowedExtensions) {
    switch (type) {
      case FileType.any:
        return '';

      case FileType.audio:
        return 'audio/*';

      case FileType.image:
        return 'image/*';

      case FileType.video:
        return 'video/*';

      case FileType.media:
        return 'video/*|image/*';

      case FileType.custom:
        return allowedExtensions.reduce((value, element) => '$value,$element');
        break;
    }
    return '';
  }
}
