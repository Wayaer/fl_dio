import 'package:dio/dio.dart';
import 'package:fl_dio/src/extended/log.dart';

class LoggerInterceptor extends InterceptorsWrapper {
  LoggerInterceptor({
    this.filtered = const [],
    this.hideRequest = const [],
    this.hideResponse = const [],
    this.printResponseHeader = false,
  });

  /// 过滤掉 完全不显示的api
  final List<String> filtered;

  /// 隐藏请求数据的 api
  /// api请求内容太多，隐藏了
  final List<String> hideRequest;

  /// 隐藏返回数据的 api
  /// api返回内容太多，隐藏了
  final List<String> hideResponse;

  /// 是否打印 response header
  final bool printResponseHeader;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri.toString();
    final isPrint = filtered.where((e) => uri.contains(e)).isEmpty;
    if (isPrint) {
      final isPrint = hideRequest.where((e) => uri.contains(e)).isEmpty;

      dioLog(
          '┌--------------------------------------------------------------------');
      dioLog('''| [DIO] Request: ${options.method} $uri
| [DIO] QueryParameters:${isPrint ? options.queryParameters : ' [Hidden] '}
| [DIO] Data:${isPrint ? options.data : ' [Hidden] '}
| [DIO] Headers:${options.headers}''');
      dioLog(
          '├--------------------------------------------------------------------');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    String requestUri = response.requestOptions.uri.toString();
    final isPrint = filtered.where((e) => requestUri.contains(e)).isEmpty;
    if (isPrint) {
      final isPrint = hideResponse.where((e) => requestUri.contains(e)).isEmpty;
      dioLog(
          '''| [DIO] Response [statusCode : ${response.statusCode}] [statusMessage : ${response.statusMessage}]'
| [DIO] Request uri: ${response.requestOptions.method} $requestUri ${printResponseHeader ? '\n| [DIO] Response headers: ${response.headers.map}' : ''}
| [DIO] Response data: ${isPrint ? '${response.data}' : ' [Hidden] '}''');
      dioLog(
          '└--------------------------------------------------------------------');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String requestUri = err.requestOptions.uri.toString();
    final isPrint = filtered.where((e) => requestUri.contains(e)).isEmpty;
    if (isPrint) {
      dioLog(
          '''| [DIO] Response [statusCode : ${err.response?.statusCode}] [statusMessage : ${err.response?.statusMessage}]
| [DIO] Request uri: ${err.requestOptions.method} $requestUri ${printResponseHeader ? '\n| [DIO] Response headers: ${err.response?.headers.map}' : ''}
| [DIO] Error: ${err.error}
| [DIO] Message: ${err.message}
| [DIO] Type: ${err.type}
| [DIO] Response: ${err.response}''');
      dioLog(
          '└------------------------------------------------------------------------------');
    }
    super.onError(err, handler);
  }
}
