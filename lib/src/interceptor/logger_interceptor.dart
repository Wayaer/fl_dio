import 'package:dio/dio.dart';
import 'package:fl_dio/src/extended/log.dart';

class LoggerInterceptor extends InterceptorsWrapper {
  LoggerInterceptor(
      {this.filtered = const [],
      this.hideRequest = const [],
      this.hideResponse = const []});

  /// 过滤掉 完全不显示的api
  final List<String> filtered;

  /// 隐藏请求数据的 api
  /// api请求内容太多，隐藏了
  final List<String> hideRequest;

  /// 隐藏返回数据的 api
  /// api返回内容太多，隐藏了
  final List<String> hideResponse;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final hide = filtered.isNotEmpty ||
        filtered.where((e) => options.uri.toString().contains(e)).isEmpty;
    if (hide) {
      String headers = '';
      options.headers.forEach((String key, dynamic value) {
        headers += ' | $key: $value';
      });

      final hide = hideRequest
          .where((e) => options.uri.toString().contains(e))
          .isNotEmpty;
      dioLog(
          '┌------------------------------------------------------------------------------');
      dioLog(
          '''| [DIO] Request: ${options.method} ${options.uri}\n| QueryParameters:${hide ? ' [Hidden] ' : options.queryParameters}\n| Data:${hide ? ' [Hidden] ' : options.data}\n| Headers:$headers''');
      dioLog(
          '├------------------------------------------------------------------------------');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    String requestUri = response.requestOptions.uri.toString();
    final hide = filtered.isNotEmpty ||
        filtered.where((e) => requestUri.toString().contains(e)).isEmpty;
    if (hide) {
      final hide = hideResponse
          .where((e) => requestUri.toString().contains(e))
          .isNotEmpty;
      dioLog(
          '| [DIO] Response [statusCode : ${response.statusCode}] [statusMessage : ${response.statusMessage}]');
      dioLog('| [DIO] Request uri ($requestUri)');
      dioLog(
          '| [DIO] Response data: ${hide ? '[Hidden]' : '\n${response.data}'}');
    }
    dioLog(
        '└------------------------------------------------------------------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final hide = filtered.isNotEmpty ||
        filtered
            .where((e) => err.requestOptions.uri.toString().contains(e))
            .isEmpty;
    if (hide) {
      dioLog(
          '| [DIO] Response [statusCode : ${err.response?.statusCode}] [statusMessage : ${err.response?.statusMessage}]');
      dioLog('| [DIO] Error: ${err.error}: ${err.response?.toString()}');
      dioLog('|            : ${err.type}: ${err.message.toString()}');
      dioLog(
          '└------------------------------------------------------------------------------');
    }
    super.onError(err, handler);
  }
}
