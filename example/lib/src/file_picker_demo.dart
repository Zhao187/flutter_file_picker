import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html;

class FilePickerDemo extends StatefulWidget {
  @override
  _FilePickerDemoState createState() => _FilePickerDemoState();
}

class _FilePickerDemoState extends State<FilePickerDemo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _fileName;
  String _path;
  Map<String, String> _paths;
  String _extension;
  bool _loadingPath = false;
  bool _multiPick = false;
  FileType _pickingType = FileType.any;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _extension = _controller.text);
  }

  void _openFileExplorer() async {
    setState(() => _loadingPath = true);
    List<String> allowedExtensions = (_extension?.isNotEmpty ?? false) ? _extension?.replaceAll(' ', '')?.split(',') : null;
    try {
      if (kIsWeb) {
        if (_multiPick) {
          _path = null;
          final list = (await FilePicker.getMultiFile(type: _pickingType, allowedExtensions: allowedExtensions)).map((e) => e.name);
          _paths = Map.fromIterable(list);
        } else {
          _paths = null;
          _path = (await FilePicker.getFile(type: _pickingType, allowedExtensions: allowedExtensions) as html.File).name;
        }
      } else if (_multiPick) {
        _path = null;
        _paths = await FilePicker.getMultiFilePath(type: _pickingType, allowedExtensions: allowedExtensions);
      } else {
        _paths = null;
        _path = await FilePicker.getFilePath(type: _pickingType, allowedExtensions: allowedExtensions);
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (!mounted) return;
    setState(() {
      _loadingPath = false;
      _fileName = _path != null ? _path.split('/').last : _paths != null ? _paths.keys.toString() : '...';
    });
  }

  void _clearCachedFiles() {
    FilePicker.clearTemporaryFiles().then((result) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          backgroundColor: result ? Colors.green : Colors.red,
          content: Text((result ? 'Temporary files removed with success.' : 'Failed to clean temporary files')),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('File Picker example app'),
        ),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: DropdownButton(
                      hint: Text('LOAD PATH FROM'),
                      value: _pickingType,
                      items: <DropdownMenuItem>[
                        DropdownMenuItem(
                          child: Text('FROM AUDIO'),
                          value: FileType.audio,
                        ),
                        DropdownMenuItem(
                          child: Text('FROM IMAGE'),
                          value: FileType.image,
                        ),
                        DropdownMenuItem(
                          child: Text('FROM VIDEO'),
                          value: FileType.video,
                        ),
                        DropdownMenuItem(
                          child: Text('FROM MEDIA'),
                          value: FileType.media,
                        ),
                        DropdownMenuItem(
                          child: Text('FROM ANY'),
                          value: FileType.any,
                        ),
                        DropdownMenuItem(
                          child: Text('CUSTOM FORMAT'),
                          value: FileType.custom,
                        ),
                      ],
                      onChanged: (value) => setState(() {
                            _pickingType = value;
                            if (_pickingType != FileType.custom) {
                              _controller.text = _extension = '';
                            }
                          })),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 100.0),
                  child: _pickingType == FileType.custom
                      ? TextFormField(
                          maxLength: 15,
                          autovalidate: true,
                          controller: _controller,
                          decoration: InputDecoration(labelText: 'File extension'),
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.none,
                        )
                      : Container(),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.tightFor(width: 200.0),
                  child: SwitchListTile.adaptive(
                    title: Text('Pick multiple files', textAlign: TextAlign.right),
                    onChanged: (bool value) => setState(() => _multiPick = value),
                    value: _multiPick,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                  child: Column(
                    children: <Widget>[
                      RaisedButton(
                        onPressed: () => _openFileExplorer(),
                        child: Text("Open file picker"),
                      ),
                      !kIsWeb
                          ? RaisedButton(
                              onPressed: () => _clearCachedFiles(),
                              child: Text("Clear temporary files"),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Builder(
                  builder: (BuildContext context) => _loadingPath
                      ? Padding(padding: const EdgeInsets.only(bottom: 10.0), child: const CircularProgressIndicator())
                      : _path != null || _paths != null
                          ? Container(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              height: MediaQuery.of(context).size.height * 0.50,
                              child: Scrollbar(
                                  child: ListView.separated(
                                itemCount: _paths != null && _paths.isNotEmpty ? _paths.length : 1,
                                itemBuilder: (BuildContext context, int index) {
                                  final bool isMultiPath = _paths != null && _paths.isNotEmpty;
                                  final String name = 'File $index: ' + (isMultiPath ? _paths.keys.toList()[index] : _fileName ?? '...');
                                  final path = isMultiPath ? _paths.values.toList()[index].toString() : _path;

                                  return ListTile(
                                    title: Text(
                                      name,
                                    ),
                                    subtitle: Text(path),
                                  );
                                },
                                separatorBuilder: (BuildContext context, int index) => Divider(),
                              )),
                            )
                          : Container(),
                ),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
