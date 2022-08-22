import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_editor/json_editor.dart';
import 'package:network_info_plus/network_info_plus.dart';

import 'mock_set.dart';
import 'utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _exportNameController = TextEditingController();
  final List<MockSet> _mockSets = [];
  String? _exportFolder;
  String? _host;

  @override
  void initState() {
    _exportNameController.text = 'data';
    NetworkInfo().getWifiIP().then((ip) => setState((() {
          if (ip != null) _host = 'http://$ip:3000/';
        })));
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
          // _wxIpAddress(),
          // _wxExportButton(),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _wxIpAddress() {
    return (Text(
      _host ?? '',
      style: const TextStyle(
        fontSize: 16,
        color: Colors.green,
        fontWeight: FontWeight.w600,
      ),
    ));
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
      onPressed: _export,
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
    final url = _host == null ? null : (_host! + _mockSets[i].name);

    return Container(
        color: Colors.amber[50],
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 30),
                Text(
                  _mockSets[i].name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                SizedBox(
                  width: 30,
                  child: IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 18,
                      color: Colors.grey[600],
                    ),
                    onPressed: () async {
                      if (url != null) {
                        await Clipboard.setData(ClipboardData(text: url));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Đã sao chép "$url"',
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    },
                    tooltip: url,
                  ),
                ),
              ],
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
                          tooltip: 'Sửa JSON',
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
          child: TextField(controller: _exportNameController),
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
          style: ElevatedButton.styleFrom(elevation: 0),
        )
      ],
    );
  }

  _onPickExportFolder() async {
    _exportFolder = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Chọn thư mục xuất file JSON');
    if (_exportFolder != null) {
      _exportFolder = _exportFolder! + Utils.pathSep;
    }
    setState(() {});
  }

  _onAddMockSet() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['json'],
        dialogTitle: 'Chọn tập tin JSON');
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

    _export();
  }

  _export() async {
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
      final text = Utils.formatJson(result);

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
      _export();
    }
  }

  _onDeleteMockSet(int i) {
    setState(() {
      _mockSets.removeAt(i);
    });
    _export();
  }

  _onToggleDisableMockSet(int i) {
    setState(() {
      _mockSets[i].disable = !_mockSets[i].disable;
    });
    _export();
  }

  _onEditEndpoint(int i, String key) {
    String json = Utils.formatJson(_mockSets[i].endpoints[key]);

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
                _export();
                Navigator.of(context).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
