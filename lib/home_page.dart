import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

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
    _pickExportFolder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Row(
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
                  decoration:
                      const InputDecoration(labelText: 'Tên tập tin xuất:'),
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
                onPressed: _pickExportFolder,
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SizedBox(
              height: 400,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _mockSets.length + 1,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (ctx, i) {
                    return SizedBox(
                      width: 300,
                      child: (i < _mockSets.length)
                          ? DottedBorder(
                              color: Colors.grey[700]!,
                              strokeWidth: 3,
                              dashPattern: const [10, 6],
                              radius: const Radius.circular(10),
                              child: Stack(children: [
                                Container(
                                    color: Colors.amber[50],
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          _mockSets[i].name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20),
                                        ),
                                        Expanded(
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Column(children: [
                                                for (var e in _mockSets[i]
                                                    .endpoints
                                                    .entries)
                                                  ListTile(
                                                    onTap: () {
                                                      _onSelect(i, e.key);
                                                    },
                                                    title: Text(e.key),
                                                    leading: Radio<String>(
                                                      value: e.key,
                                                      groupValue:
                                                          _mockSets[i].selected,
                                                      onChanged: (value) {
                                                        _onSelect(i, value);
                                                      },
                                                    ),
                                                  ),
                                              ]),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _mockSets.removeAt(i);
                                        });
                                      },
                                    )),
                              ]),
                            )
                          : InkWell(
                              onTap: _addMockSet,
                              child: DottedBorder(
                                color: Colors.grey[700]!,
                                strokeWidth: 3,
                                dashPattern: const [10, 6],
                                radius: const Radius.circular(10),
                                child: Container(
                                    color: Colors.green[50],
                                    child: const Center(
                                        child: Icon(Icons.add, size: 60))),
                              ),
                            ),
                    );
                  }),
            ),
          ),
          const SizedBox(height: 20),
          // ElevatedButton(
          //   child: const Padding(
          //     padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          //     child: Text(
          //       'XUẤT',
          //       style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          //     ),
          //   ),
          //   // onPressed: _export,
          //   onPressed: _export,
          // ),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  _pickExportFolder() async {
    _exportFolder = await FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Chọn thư mục xuất file JSON');
    if (_exportFolder != null) {
      _exportFolder = _exportFolder! + '\\';
    }
    setState(() {});
  }

  _addMockSet() async {
    final result = await FilePicker.platform
        .pickFiles(allowMultiple: true, allowedExtensions: ['json']);

    if (result != null) {
      for (var path in result.paths) {
        final mockSet = await MockSet.fromFile(path);
        if (mockSet != null) {
          _mockSets.add(mockSet);
        }
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
        result[mockSet.name] = mockSet.endpoints[mockSet.selected];
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
      _export();
    }
  }
}

class MockSetCard extends StatefulWidget {
  const MockSetCard(
    this.mockSet, {
    Key? key,
  }) : super(key: key);

  final MockSet mockSet;

  @override
  State<MockSetCard> createState() => _MockSetCardState();
}

class _MockSetCardState extends State<MockSetCard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: widget.mockSet.endpoints.entries
            .map(
              (e) => ListTile(
                title: Text(e.key),
                leading: Radio<String>(
                  value: widget.mockSet.selected,
                  groupValue: e.key,
                  onChanged: (value) {
                    if (value != null && value != widget.mockSet.selected) {
                      setState(() {
                        widget.mockSet.selected = value;
                      });
                    }
                  },
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
