import 'package:flutter_test/flutter_test.dart';
import 'package:fur_friend_diary/main.dart';

void main() {
  testWidgets('App builds and has nav bar', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Feedings'), findsWidgets);
  });
}
