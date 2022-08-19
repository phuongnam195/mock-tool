import 'dart:convert';
import 'dart:io';

class MockSet {
  final String path;
  final String name;
  final Map<String, dynamic> endpoints;
  String selected;

  MockSet(this.path, this.name, this.endpoints, this.selected);

  static Future<MockSet?> fromFile(String? path) async {
    if (path == null) return null;

    try {
      final file = File(path);
      final text = await file.readAsString();

      Map<String, dynamic> endpoints = jsonDecode(text);

      String name = file.path.split('\\').last;
      name = name.substring(0, name.lastIndexOf('.'));

      return MockSet(path, name, endpoints, endpoints.keys.first);
    } catch (e) {
      print(e);
    }
    return null;
  }
}
