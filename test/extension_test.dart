import 'dart:typed_data';

import 'package:fl_dio/fl_dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtensionRequestOptions.toMap', () {
    test('保留 Map data，超时转为毫秒，responseType 使用 name', () {
      final RequestOptions options = RequestOptions(
        path: '/x',
        connectTimeout: const Duration(seconds: 15),
        data: <String, dynamic>{'a': 1},
      );

      final Map<String, dynamic> map = options.toMap();

      expect(map['data'], <String, dynamic>{'a': 1});
      expect(map['connectTimeout'], 15000);
      expect(map['responseType'], 'json');
    });

    test('非集合 data 转为字符串，保证可打印', () {
      final RequestOptions options = RequestOptions(path: '/upload', data: FormData());

      final Map<String, dynamic> map = options.toMap();

      expect(map['data'], isA<String>());
      expect(map['data'], contains('FormData'));
    });

    test('空 data 保持 null', () {
      expect(RequestOptions(path: '/x').toMap()['data'], isNull);
    });
  });

  group('ExtensionUri', () {
    test('数据 URI 的 toMap 不会无限递归', () {
      final Uri uri = Uri.dataFromString('hello');

      final Map<String, dynamic> map = uri.toMap();
      final Map<String, dynamic> data = map['data'] as Map<String, dynamic>;

      expect(data['mimeType'], 'text/plain');
      expect(data['uri'], isA<String>());
      expect(uri.data?.toMap()['uri'], isA<String>());
    });
  });

  group('ExtensionResponse.toMap', () {
    test('List 数据原样保留', () {
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        data: <dynamic>[1, 2],
      );
      expect(response.toMap()['data'], <dynamic>[1, 2]);
    });

    test('JSON 字符串会被解析', () {
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        data: '{"a":1}',
      );
      expect(response.toMap()['data'], <String, dynamic>{'a': 1});
    });

    test('字节数据输出摘要', () {
      final Response<dynamic> response = Response<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        data: Uint8List.fromList(<int>[1, 2, 3]),
      );
      final dynamic summary = response.toMap()['data'];
      expect(summary, isA<String>());
      expect(summary, contains('[3]'));
    });

    test('FlResponse 使用相同的转换规则', () {
      final FlResponse<dynamic> jsonResponse = FlResponse<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        data: '{"a":1}',
      );
      expect(jsonResponse.toMap()['data'], <String, dynamic>{'a': 1});

      final FlResponse<dynamic> bytesResponse = FlResponse<dynamic>(
        requestOptions: RequestOptions(path: '/'),
        data: Uint8List.fromList(<int>[1, 2, 3]),
      );
      expect(bytesResponse.toMap()['data'], contains('[3]'));
    });
  });
}
