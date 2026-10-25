import 'dart:typed_data';

import 'package:fl_dio/fl_dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) =>
      onFetch(options);

  @override
  void close({bool force = false}) {}
}

FlDio _createDio(_FakeAdapter adapter) {
  final FlDio dio = FlDio(BaseOptions(baseUrl: 'https://api.example.com'));
  dio.httpClientAdapter = adapter;
  return dio;
}

void main() {
  group('FlDio', () {
    test('成功请求返回 FlResponse', () async {
      RequestOptions? lastOptions;
      final FlDio dio = _createDio(
        _FakeAdapter((RequestOptions options) {
          lastOptions = options;
          return Future<ResponseBody>.value(
            ResponseBody.fromString(
              '{"ok":true}',
              200,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>[Headers.jsonContentType],
                'set-cookie': <String>['token=1'],
              },
            ),
          );
        }),
      );

      final FlResponse<Map<String, dynamic>> response = await dio.get<Map<String, dynamic>>(
        '/ok',
        queryParameters: <String, dynamic>{'a': 1},
      );

      expect(response, isA<FlResponse<Map<String, dynamic>>>());
      expect(response.statusCode, 200);
      expect(response.data, <String, dynamic>{'ok': true});
      expect(response.cookie, <String>['token=1']);
      expect(response.exception, isNull);
      expect(lastOptions?.path, '/ok');
      expect(lastOptions?.queryParameters['a'], 1);
    });

    test('错误状态码不抛异常并合并响应体', () async {
      final FlDio dio = _createDio(
        _FakeAdapter((RequestOptions options) {
          return Future<ResponseBody>.value(
            ResponseBody.fromString(
              '{"message":"boom"}',
              500,
              headers: <String, List<String>>{
                Headers.contentTypeHeader: <String>[Headers.jsonContentType],
                'set-cookie': <String>['token=1'],
              },
            ),
          );
        }),
      );

      final FlResponse<Map<String, dynamic>> response = await dio.get<Map<String, dynamic>>('/fail');

      expect(response.statusCode, 500);
      expect(response.data, <String, dynamic>{'message': 'boom'});
      expect(response.exception, isA<DioException>());
      expect(response.cookie, <String>['token=1']);
    });

    test('clone 返回 FlDio 并保留配置', () {
      final FlDio dio = FlDio(BaseOptions(baseUrl: 'https://api.example.com'));
      dio.options.headers['x-token'] = 'abc';

      final FlDio cloned = dio.clone();

      expect(cloned, isA<FlDio>());
      expect(cloned.options.baseUrl, 'https://api.example.com');
      expect(cloned.options.headers['x-token'], 'abc');
      expect(cloned.interceptors.length, dio.interceptors.length);
    });
  });

  group('CookiesInterceptor', () {
    test('setCookies 返回 null 时不写入请求头', () {
      final RequestOptions options = RequestOptions(path: '/');
      CookiesInterceptor(setCookies: (RequestOptions options) => null).onRequest(options, RequestInterceptorHandler());
      expect(options.headers, isEmpty);
    });

    test('setCookies 返回空 Map 时不写入请求头', () {
      final RequestOptions options = RequestOptions(path: '/');
      CookiesInterceptor(setCookies: (RequestOptions options) => <String, dynamic>{})
          .onRequest(options, RequestInterceptorHandler());
      expect(options.headers, isEmpty);
    });

    test('setCookies 返回内容时合并到请求头', () {
      final RequestOptions options = RequestOptions(path: '/');
      CookiesInterceptor(setCookies: (RequestOptions options) => <String, dynamic>{'Cookie': 'token=1'})
          .onRequest(options, RequestInterceptorHandler());
      expect(options.headers['Cookie'], 'token=1');
    });
  });
}
