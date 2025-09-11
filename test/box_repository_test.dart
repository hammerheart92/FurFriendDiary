
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fur_friend_diary/src/services/box_repository.dart';

void main() {
  test('BoxRepository basic encode/decode roundtrip', () async {
    await Hive.initFlutter();
    final repo = BoxRepository('testbox');
    await repo.put('1', {'hello': 'world'});
    final got = await repo.get('1');
    expect(got?['hello'], 'world');
    await Hive.close();
  });
}
