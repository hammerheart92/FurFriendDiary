
import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// A generic repository storing JSON-serializable records by box.
class BoxRepository {
  final String boxName;
  BoxRepository(this.boxName);

  Future<void> ensureOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
  }

  Future<void> put(String id, Map<String, dynamic> json) async {
    await ensureOpen();
    final box = Hive.box<String>(boxName);
    await box.put(id, jsonEncode(json));
  }

  Future<Map<String, dynamic>?> get(String id) async {
    await ensureOpen();
    final v = Hive.box<String>(boxName).get(id);
    return v == null ? null : jsonDecode(v) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listAll() async {
    await ensureOpen();
    final box = Hive.box<String>(boxName);
    return box.values.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  Future<void> delete(String id) async {
    await ensureOpen();
    await Hive.box<String>(boxName).delete(id);
  }

  Future<void> clear() async {
    await ensureOpen();
    await Hive.box<String>(boxName).clear();
  }
}
