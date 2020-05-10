import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'file_picker_platform_interface.dart';

const MethodChannel _channel =
    MethodChannel('miguelruivo.flutter.plugins.filepicker');

/// An implementation of [FilePickerPlatform] that uses method channels.
class MethodChannelFilePicker extends FilePickerPlatform {
  static const String _tag = 'MethodChannelFilePicker';

  @override
  Future getFiles({
    FileType type = FileType.any,
    List<String> allowedExtensions,
    bool allowMultiple = false,
  }) =>
      _getPath(type, allowMultiple, allowedExtensions);

  @override
  Future<bool> clearTemporaryFiles() async =>
      _channel.invokeMethod<bool>('clear');

  Future<dynamic> _getPath(
    FileType fileType,
    bool allowMultipleSelection,
    List<String> allowedExtensions,
  ) async {
    final String type = describeEnum(fileType);
    if (type != 'custom' && (allowedExtensions?.isNotEmpty ?? false)) {
      throw Exception(
          'If you are using a custom extension filter, please use the FileType.custom instead.');
    }
    try {
      dynamic result = await _channel.invokeMethod(type, {
        'allowMultipleSelection': allowMultipleSelection,
        'allowedExtensions': allowedExtensions,
      });
      if (result != null && allowMultipleSelection) {
        if (result is String) {
          result = [result];
        }
        return Map<String, String>.fromIterable(result,
            key: (path) => path.split('/').last, value: (path) => path);
      }
      return result;
    } on PlatformException catch (e) {
      print('[$_tag] Platform exception: $e');
      rethrow;
    } catch (e) {
      print(
          '[$_tag] Unsupported operation. Method not found. The exception thrown was: $e');
      rethrow;
    }
  }
}
