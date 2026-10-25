import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('达到 maxDepth 后不再展开循环引用', (WidgetTester tester) async {
    JsonParse.maxDepth = 1;
    addTearDown(() => JsonParse.maxDepth = 20);

    final Map<String, dynamic> circular = <String, dynamic>{};
    circular['self'] = circular;

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: JsonParse(circular))));
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();

    // 只有根节点保留箭头，子层不再可展开
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    expect(find.textContaining('max depth'), findsOneWidget);
  });

  testWidgets('可以放在 ListView 等高度无界的环境中', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
        home: Scaffold(
            body: ListView(children: <Widget>[
      JsonParse(<String, dynamic>{'a': 1, 'b': <int>[1, 2]})
    ]))));

    expect(tester.takeException(), isNull);
    expect(find.text('a:'), findsOneWidget);
  });
}
