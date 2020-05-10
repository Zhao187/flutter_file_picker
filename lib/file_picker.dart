import 'dart:async';

import 'file_picker_io.dart' if (dart.library.html) 'file_picker_web.dart';

enum FileType {
  any,
  media,
  image,
  video,
  audio,
  custom,
}

abstract class FilePicker {
  FilePicker._();

  /// Returns an iterable `Map<String,String>` where the `key` is the name of the file
  /// and the `value` the path.
  ///
  /// A `List` with [allowedExtensions] can be provided to filter the allowed files to picked.
  /// If provided, make sure you select `FileType.custom` as type.
  /// Defaults to `FileType.any`, which allows any combination of files to be multi selected at once.
  static Future<Map<String, String>> getMultiFilePath({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      FilePickerInterface.getMultiFilePath(type: type, allowedExtensions: allowedExtensions);

  /// Returns an absolute file path from the calling platform.
  ///
  /// Extension filters are allowed with `FileType.custom`, when used, make sure to provide a `List`
  /// of [allowedExtensions] (e.g. [`pdf`, `svg`, `jpg`].).
  /// Defaults to `FileType.any` which will display all file types.
  static Future<String> getFilePath({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      FilePickerInterface.getFilePath(type: type, allowedExtensions: allowedExtensions);

  /// Returns a `File` object from the selected file path.
  ///
  /// This is an utility method that does the same of `getFilePath()` but saving some boilerplate if
  /// you are planing to create a `File` for the returned path.
  static Future<dynamic> getFile({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      FilePickerInterface.getFile(type: type, allowedExtensions: allowedExtensions);

  /// Returns a `List<File>` object from the selected files paths.
  ///
  /// This is an utility method that does the same of `getMultiFilePath()` but saving some boilerplate if
  /// you are planing to create a list of `File`s for the returned paths.
  static Future<List<dynamic>> getMultiFile({FileType type = FileType.any, List<String> allowedExtensions}) async =>
      FilePickerInterface.getMultiFile(type: type, allowedExtensions: allowedExtensions);

  /// Asks the underlying platform to remove any temporary files created by this plugin.
  ///
  /// This typically relates to cached files that are stored in the cache directory of
  /// each platform and it isn't required to invoke this as the system should take care
  /// of it whenever needed. However, this will force the cleanup if you want to manage those on your own.
  ///
  /// Returns `true` if the files were removed with success, `false` otherwise.
  static Future<bool> clearTemporaryFiles() async => FilePickerInterface.clearTemporaryFiles();
}
