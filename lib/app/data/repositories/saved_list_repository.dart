import 'dart:convert';

import 'package:get_storage/get_storage.dart';

import '../models/saved_list.dart';

class SavedListRepository {
  static const _key = 'previous_lists';
  final GetStorage _box = GetStorage();

  List<SavedList> load() {
    final raw = _box.read<List<dynamic>>(_key);
    if (raw == null) return [];
    final lists = <SavedList>[];
    for (final entry in raw) {
      try {
        final map = entry is String
            ? Map<String, dynamic>.from(jsonDecode(entry) as Map)
            : Map<String, dynamic>.from(entry as Map);
        lists.add(SavedList.fromJson(map));
      } catch (_) {
        continue;
      }
    }
    return lists;
  }

  void save(List<SavedList> lists) =>
      _box.write(_key, lists.map((e) => e.toJson()).toList());

  int nextId(List<SavedList> lists) => lists.isEmpty
      ? 1
      : lists.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
}
