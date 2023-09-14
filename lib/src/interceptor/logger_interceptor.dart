import 'package:dio/dio.dart';
import 'package:fl_dio/src/log.dart';

class LoggerInterceptor extends InterceptorsWrapper {
  LoggerInterceptor({this.filteredApi = const []});

  final List<String> filteredApi;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String headers = '';
    options.headers.forEach((String key, dynamic value) {
      headers += ' | $key: $value';
    });
    log('┌------------------------------------------------------------------------------');
    log('''| [DIO] Request: ${options.method} ${options.uri}\n| QueryParameters:${options.queryParameters}\n| Data:${options.data}\n| Headers:$headers''');
    log('├------------------------------------------------------------------------------');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    bool forbidPrint = false;
    String requestUri = response.requestOptions.uri.toString();
    for (var element in filteredApi) {
      if (requestUri.toString().contains(element)) {
        forbidPrint = true;
        break;
      }
    }
    log('| [DIO] Response [statusCode : ${response.statusCode}] [statusMessage : ${response.statusMessage}]');
    log('| [DIO] Request uri ($requestUri)');
    log('| [DIO] Response data: ${forbidPrint ? 'This data is not printed' : '\n${response.data}'}');
    log('└------------------------------------------------------------------------------');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log('| [DIO] Response [statusCode : ${err.response?.statusCode}] [statusMessage : ${err.response?.statusMessage}]');
    log('| [DIO] Error: ${err.error}: ${err.response?.toString()}');
    log('|            : ${err.type}: ${err.message.toString()}');
    log('└------------------------------------------------------------------------------');
    super.onError(err, handler);
  }
}
