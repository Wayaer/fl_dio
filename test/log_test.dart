import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

List<String> _captureLogs(VoidCallback action) {
  final List<String> logs = <String>[];
  final DebugPrintCallback original = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) {
    if (message != null) logs.add(message);
  };
  try {
    action();
  } finally {
    debugPrint = original;
  }
  return logs;
}

void main() {
  group('LoggerInterceptor', () {
    test('默认遮蔽敏感 header', () {
      final RequestOptions options = RequestOptions(
        path: '/secure',
        headers: <String, dynamic>{'Authorization': 'Bearer secret', 'X-Trace': 'ok'}
      );

      final List<String> logs = _captureLogs(
          () => LoggerInterceptor().onRequest(options, RequestInterceptorHandler()));

      final String output = logs.join('\n');
      expect(output, contains('***'));
      expect(output, isNot(contains('Bearer secret')));
      expect(output, contains('X-Trace'));
    });

    test('redactHeaders 为空时原样输出', () {
      final RequestOptions options = RequestOptions(
        path: '/secure',
        headers: <String, dynamic>{'Authorization': 'Bearer secret'}
      );

      final List<String> logs = _captureLogs(
          () => LoggerInterceptor(redactHeaders: const <String>[]).onRequest(options, RequestInterceptorHandler()));

      expect(logs.join('\n'), contains('Bearer secret'));
    });
  });

  group('dioLog', () {
    test('输出恰好 800 字符的消息', () {
      final String message = 'a' * 800;
      final List<String> logs = _captureLogs(() => dioLog(message));
      expect(logs, hasLength(1));
      expect(logs.single, message);
    });

    test('超长消息分块后内容不变', () {
      final String message = 'x' * 1700;
      final List<String> logs = _captureLogs(() => dioLog(message));
      expect(logs, hasLength(3));
      expect(logs.join(), message);
    });

    test('不在代理对中间截断', () {
      final String message = 'a${'😀' * 600}';
      final List<String> logs = _captureLogs(() => dioLog(message));
      expect(logs.join(), message);
      for (final String chunk in logs) {
        final int last = chunk.codeUnitAt(chunk.length - 1);
        expect(last >= 0xD800 && last <= 0xDBFF, isFalse);
      }
    });

    test('多行日志逐行输出', () {
      final List<String> logs = _captureLogs(() => dioLog('line1\nline2'));
      expect(logs, <String>['line1', 'line2']);
    });
  });
}
