import 'dart:convert';
import 'package:fl_dio/fl_dio.dart';

class LoggerInterceptor extends InterceptorsWrapper {
  LoggerInterceptor({
    this.filtered = const [],
    this.hideRequest = const [],
    this.hideResponse = const [],
    this.printResponseHeader = false,
    this.printErrorResponse = false,
    this.requestQueryParametersToJson = true,
    this.requestDataToJson = true,
    this.requestHeaderToJson = true,
    this.responseToJson = true,
    this.isPrintBytes = false,
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

  /// 打印错误信息
  /// 当请求失败时，打印错误信息
  final bool printErrorResponse;

  /// 请求参数转 json
  /// 参数必须为 [Map] 才会转
  final bool requestQueryParametersToJson;

  /// 请求参数转 json
  /// 参数必须为 [Map] 才会转
  final bool requestDataToJson;

  /// map 转 json
  /// 参数必须为 [Map] 才会转
  final bool requestHeaderToJson;

  /// 返回数据转 json
  /// 返回数据必须为 [Map] 才会转
  final bool responseToJson;

  /// 是否打印 bytes
  final bool isPrintBytes;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri.toString();
    final isPrint = filtered.where((e) => uri.contains(e)).isEmpty;
    if (isPrint) {
      final isPrint = hideRequest.where((e) => uri.contains(e)).isEmpty;

      dioLog(
          '┌--------------------------------------------------------------------');
      dioLog('''| [DIO | onRequest] Request: ${options.method} $uri
| [DIO | onRequest] QueryParameters:${convertData(options.queryParameters, isPrint: isPrint, toJson: requestQueryParametersToJson)}
| [DIO | onRequest] Data:${convertData(options.data, isPrint: isPrint, toJson: requestDataToJson, responseType: options.responseType)}
| [DIO | onRequest] Headers:${convertData(options.headers, isPrint: isPrint, toJson: requestHeaderToJson)}''');
      dioLog(
          '├--------------------------------------------------------------------');
    }
    super.onRequest(options, handler);
  }

  dynamic convertData(
    dynamic data, {
    bool isPrint = false,
    bool toJson = false,
    ResponseType? responseType,
  }) {
    if (!isPrint) return ' [${data.runtimeType} Hidden] ';
    if (data is Map && toJson) {
      try {
        return jsonEncode(data);
      } catch (e) {
        dioLog('LoggerInterceptor to json error :$e');
      }
    } else if (responseType == ResponseType.bytes && !isPrintBytes) {
      return 'ResponseType.bytes: ${data?.runtimeType} [${data is List ? data.length : '0'}]';
    } else if (responseType == ResponseType.stream && data is ResponseBody) {
      return 'ResponseType.stream: ${data.runtimeType} [${data.contentLength}]';
    }
    return data;
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    String requestUri = response.requestOptions.uri.toString();
    final isPrint = filtered.where((e) => requestUri.contains(e)).isEmpty;
    if (isPrint) {
      final isPrint = hideResponse.where((e) => requestUri.contains(e)).isEmpty;
      dioLog(
          '''| [DIO | onResponse] Response [statusCode : ${response.statusCode}] [statusMessage : ${response.statusMessage}]
| [DIO | onResponse] Request uri: ${response.requestOptions.method} $requestUri ${printResponseHeader ? '\n| [DIO | onResponse] Response headers: ${convertData(response.headers.map, toJson: requestHeaderToJson)}' : ''}
| [DIO | onResponse] Response data: ${convertData(response.data, isPrint: isPrint, toJson: responseToJson, responseType: response.requestOptions.responseType)}''');
      dioLog(
          '└--------------------------------------------------------------------');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String requestUri = err.requestOptions.uri.toString();
    final isPrint = filtered.where((e) => requestUri.contains(e)).isEmpty;
    dioLog(
        '''| [DIO | error] Response [statusCode : ${err.response?.statusCode}] [statusMessage : ${err.response?.statusMessage}]
| [DIO | onError] Request uri: ${err.requestOptions.method} $requestUri ${printResponseHeader ? '\n| [DIO | onError] Response headers: ${convertData(err.response?.headers.map, toJson: requestHeaderToJson, isPrint: true)}' : ''}
| [DIO | onError] Error: ${err.error}
| [DIO | onError] Message: ${err.message}
| [DIO | onError] Type: ${err.type} ${printErrorResponse ? '\n| [DIO | onError] Response: ${convertData(err.response?.toMap(), toJson: responseToJson, responseType: err.response?.requestOptions.responseType, isPrint: isPrint)}' : ''}''');
    dioLog(
        '└------------------------------------------------------------------------------');
    super.onError(err, handler);
  }
}
