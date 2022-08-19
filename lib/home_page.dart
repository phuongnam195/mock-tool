import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:json_editor/json_editor.dart';

import 'mock_set.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _exportNameController = TextEditingController();
  final List<MockSet> _mockSets = [];
  String? _exportFolder;

  @override
  void initState() {
    _exportNameController.text = 'data';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          _wxHeader(),
          const SizedBox(height: 20),
          Expanded(child: _wxListMockSet()),
          const SizedBox(height: 20),
          // _wxExportButton(),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _wxExportButton() {
    return ElevatedButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Text(
          'XUẤT',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      // onPressed: _export,
      onPressed: _onExport,
    );
  }

  Widget _wxListMockSet() {
    return SizedBox(
      height: 400,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _mockSets.length + 1,
          padding: const EdgeInsets.all(10),
          itemBuilder: (ctx, i) {
            return Container(
              padding: const EdgeInsets.all(4),
              width: 350,
              child: (i < _mockSets.length)
                  ? DottedBorder(
                      color: Colors.grey[700]!,
                      strokeWidth: 3,
                      dashPattern: const [10, 6],
                      radius: const Radius.circular(10),
                      child: Stack(children: [
                        _wxMockSetCard(i),
                        Positioned(top: 0, right: 0, child: _wxDeleteButton(i)),
                      ]),
                    )
                  : _wxAddMockSet(),
            );
          }),
    );
  }

  Widget _wxAddMockSet() {
    return InkWell(
      onTap: _onAddMockSet,
      child: DottedBorder(
        color: Colors.grey[700]!,
        strokeWidth: 3,
        dashPattern: const [10, 6],
        radius: const Radius.circular(10),
        child: Container(
            color: Colors.green[50],
            child: const Center(child: Icon(Icons.add, size: 60))),
      ),
    );
  }

  Widget _wxMockSetCard(int i) {
    return Container(
        color: Colors.amber[50],
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _mockSets[i].name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(children: [
                    for (var e in _mockSets[i].endpoints.entries)
                      RadioListTile<String>(
                        title: Text(e.key),
                        value: e.key,
                        groupValue: _mockSets[i].selected,
                        onChanged: (value) {
                          _onSelect(i, value);
                        },
                        secondary: IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _onEditEndpoint(i, e.key),
                        ),
                      ),
                  ]),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    _mockSets[i].disable
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color:
                        _mockSets[i].disable ? Colors.yellow[900] : Colors.grey,
                    size: 30,
                  ),
                  onPressed: () {
                    _onToggleDisableMockSet(i);
                  },
                  tooltip: _mockSets[i].disable ? 'Bật' : 'Tắt',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ));
  }

  Widget _wxDeleteButton(int i) {
    return IconButton(
      icon: const Icon(
        Icons.cancel,
        color: Colors.red,
      ),
      onPressed: () {
        _onDeleteMockSet(i);
      },
      tooltip: 'Xóa',
    );
  }

  Widget _wxHeader() {
    return Row(
      children: [
        Text(
          _exportFolder ?? 'Chưa chọn',
          style: TextStyle(
            fontSize: 16,
            color: _exportFolder == null ? Colors.red : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 25),
        Expanded(
          child: TextField(
            controller: _exportNameController,
            decoration: const InputDecoration(labelText: 'Tên tập tin xuất:'),
          ),
        ),
        const Text('.json',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(width: 30),
        ElevatedButton(
          child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Chọn thư mục',
                style: TextStyle(fontSize: 16),
              )),
          onPressed: _onPickExportFolder,
        )
      ],
    );
  }

  _onPickExportFolder() async {
    _exportFolder = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Chọn thư mục xuất file JSON');
    if (_exportFolder != null) {
      _exportFolder = _exportFolder! + '\\';
    }
    setState(() {});
  }

  _onAddMockSet() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, allowedExtensions: ['json']);
    await _addMockSet(result?.paths);
  }

  _addMockSet(List<String?>? paths) async {
    if (paths == null) return;

    for (var path in paths) {
      final mockSet = await MockSet.fromFile(path);
      if (mockSet != null) {
        _mockSets.add(mockSet);
      }
    }

    setState(() {});

    _onExport();
  }

  _onExport() async {
    if (_exportFolder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chưa chọn thư mục xuất file')));
      return;
    }

    try {
      Map<String, dynamic> result = {};
      for (var mockSet in _mockSets) {
        if (!mockSet.disable) {
          result[mockSet.name] = mockSet.endpoints[mockSet.selected];
        }
      }
      final text = const JsonEncoder.withIndent('    ').convert(result);

      final exportFile =
          File(_exportFolder! + _exportNameController.text + '.json');

      await exportFile.writeAsString(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        'Lỗi: $e',
        overflow: TextOverflow.ellipsis,
      )));
    }
  }

  _onSelect(int i, String? value) {
    if (value != null && value != _mockSets[i].selected) {
      setState(() {
        _mockSets[i].selected = value;
      });
      _onExport();
    }
  }

  _onDeleteMockSet(int i) {
    setState(() {
      _mockSets.removeAt(i);
    });
    _onExport();
  }

  _onToggleDisableMockSet(int i) {
    setState(() {
      _mockSets[i].disable = !_mockSets[i].disable;
    });
    _onExport();
  }

  _onEditEndpoint(int i, String key) {
    String json = const JsonEncoder.withIndent('    ')
        .convert(_mockSets[i].endpoints[key]);

    String edittedJson = json;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(
          key,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        content: JsonEditor.string(
          jsonString: json,
          onValueChanged: (value) {
            edittedJson = JsonElement.fromJson(value.toJson()).toString();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6),
            child: TextButton(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Text('Hủy'),
              ),
              style: TextButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
                primary: Colors.grey,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: TextButton(
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                child: Text('Lưu'),
              ),
              style: TextButton.styleFrom(
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                _mockSets[i].endpoints[key] = jsonDecode(edittedJson);
                _mockSets[i].save();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
