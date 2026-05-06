import 'package:fl_dio/fl_dio.dart';

class ExtendedResponse<T> extends Response<T> {
  ExtendedResponse({
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
  });

  /// 请求返回类型 [DioException]
  DioExceptionType? type;

  /// exception 信息
  Object? exception;

  /// 保存的cookie
  List<String> cookie = <String>[];

  static ExtendedResponse<T> mergeDioException<T>(DioException exception) =>
      ExtendedResponse(
          type: exception.type,
          exception: exception,
          requestOptions: exception.requestOptions);

  static ExtendedResponse<T> generalExtendedResponse<T>({Object? exception}) =>
      ExtendedResponse<T>(
          exception: exception,
          requestOptions: RequestOptions(path: ''),
          statusCode: 0,
          statusMessage: 'unknown exception',
          type: DioExceptionType.unknown);
}
