import 'package:fl_dio/fl_dio.dart';

class FlResponse<T> extends Response<T> {
  FlResponse({
    required super.requestOptions,
    super.data,
    super.statusCode,
    super.statusMessage,
    super.headers,
    super.redirects,
    super.extra,
    super.isRedirect,
    this.exception,
    this.type,
    List<String>? cookie,
  }) : cookie = cookie ?? <String>[];

  /// 请求返回类型 [DioException]
  DioExceptionType? type;

  /// exception 信息
  Object? exception;

  /// 响应中的 Set-Cookie
  List<String> cookie;

  static FlResponse<T> mergeDioException<T>(DioException exception) {
    final Response<dynamic>? response = exception.response;
    T? data;
    final dynamic responseData = response?.data;
    if (responseData is T) data = responseData;
    return FlResponse<T>(
      requestOptions: exception.requestOptions,
      type: exception.type,
      exception: exception,
      data: data,
      statusCode: response?.statusCode,
      statusMessage: response?.statusMessage,
      headers: response?.headers,
      redirects: response?.redirects ?? const <RedirectRecord>[],
      extra: response?.extra ?? <String, dynamic>{},
      isRedirect: response?.isRedirect ?? false,
      cookie: response?.headers['set-cookie']?.toList(),
    );
  }

  static FlResponse<T> generalFlResponse<T>({Object? exception}) => FlResponse<T>(
    exception: exception,
    requestOptions: RequestOptions(path: ''),
    statusCode: 0,
    statusMessage: 'unknown exception',
    type: DioExceptionType.unknown,
  );
}
