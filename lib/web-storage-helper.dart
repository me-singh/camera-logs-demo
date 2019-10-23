import 'dart:html';
import 'dart:convert';

class LocalStorage {

  final Storage _localStorage = window.localStorage;

  int getSize() {
    return _localStorage.length;
  }

  void save(String key, dynamic value) {
    _localStorage[key] = jsonEncode(value);
  }

  dynamic getValue(String key) => jsonDecode(_localStorage[key]);

  invalidate() async {
    _localStorage.clear();
  }

}