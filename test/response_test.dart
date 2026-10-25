import 'package:fl_dio/fl_dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlResponse', () {
    test('cookie 默认为空列表', () {
      final FlResponse<dynamic> response = FlResponse<dynamic>(requestOptions: RequestOptions(path: '/'));
      expect(response.cookie, isEmpty);
      expect(response.type, isNull);
      expect(response.exception, isNull);
    });

    test('mergeDioException 合并 response 字段', () {
      final RequestOptions options = RequestOptions(path: '/fail');
      final Response<Map<String, dynamic>> source = Response<Map<String, dynamic>>(
        requestOptions: options,
        data: <String, dynamic>{'message': 'boom'},
        statusCode: 500,
        statusMessage: 'Server Error',
        headers: Headers.fromMap(<String, List<String>>{
          'set-cookie': <String>['token=1', 'source=demo'],
        }),
      );
      final DioException exception = DioException(
        requestOptions: options,
        response: source,
        type: DioExceptionType.badResponse,
      );

      final FlResponse<Map<String, dynamic>> merged = FlResponse.mergeDioException<Map<String, dynamic>>(exception);

      expect(merged.statusCode, 500);
      expect(merged.statusMessage, 'Server Error');
      expect(merged.data, <String, dynamic>{'message': 'boom'});
      expect(merged.cookie, <String>['token=1', 'source=demo']);
      expect(merged.type, DioExceptionType.badResponse);
      expect(merged.exception, same(exception));
      expect(merged.headers, same(source.headers));
    });

    test('mergeDioException 类型不匹配时 data 为空', () {
      final RequestOptions options = RequestOptions(path: '/fail');
      final DioException exception = DioException(
        requestOptions: options,
        response: Response<dynamic>(requestOptions: options, data: <String, dynamic>{'a': 1}, statusCode: 400),
        type: DioExceptionType.badResponse,
      );

      final FlResponse<String> merged = FlResponse.mergeDioException<String>(exception);

      expect(merged.data, isNull);
      expect(merged.statusCode, 400);
      expect(merged.cookie, isEmpty);
      expect(merged.redirects, isEmpty);
    });

    test('mergeDioException 无 response 时使用默认值', () {
      final DioException exception = DioException(
        requestOptions: RequestOptions(path: '/x'),
        type: DioExceptionType.connectionTimeout,
      );
      final FlResponse<dynamic> merged = FlResponse.mergeDioException<dynamic>(exception);

      expect(merged.statusCode, isNull);
      expect(merged.data, isNull);
      expect(merged.isRedirect, isFalse);
      expect(merged.type, DioExceptionType.connectionTimeout);
    });

    test('generalFlResponse 标记 unknown', () {
      final FlResponse<dynamic> response = FlResponse.generalFlResponse<dynamic>(exception: 'oops');
      expect(response.statusCode, 0);
      expect(response.exception, 'oops');
      expect(response.type, DioExceptionType.unknown);
    });
  });
}
