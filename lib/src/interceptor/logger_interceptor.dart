import 'dart:convert';

import 'package:fl_dio/fl_dio.dart';

/// 统一格式化的请求日志拦截器。
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
    this.prettyJson = true,
    this.printDuration = true,
    this.redactHeaders = const <String>['authorization', 'cookie', 'set-cookie', 'proxy-authorization'],
  });

  /// 完全不打印的 api，命中任意一个字符串即跳过
  final List<String> filtered;

  /// 打印时脱敏的 header 名称，不区分大小写；设为空列表可关闭脱敏
  final List<String> redactHeaders;

  /// 隐藏请求数据的 api
  final List<String> hideRequest;

  /// 隐藏响应数据的 api
  final List<String> hideResponse;

  /// 是否打印响应头
  final bool printResponseHeader;

  /// 请求失败时是否打印响应体
  final bool printErrorResponse;

  /// 请求参数转 json
  final bool requestQueryParametersToJson;

  /// 请求数据转 json
  final bool requestDataToJson;

  /// 请求头转 json
  final bool requestHeaderToJson;

  /// 响应数据转 json
  final bool responseToJson;

  /// 是否打印 bytes 内容
  final bool isPrintBytes;

  /// Map / List 是否缩进输出
  final bool prettyJson;

  /// 是否打印请求耗时
  final bool printDuration;

  /// 用 Expando 记录请求开始时间，不污染 [RequestOptions.extra]
  final Expando<DateTime> _requestTime = Expando<DateTime>('fl_dio_request_time');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String uri = options.uri.toString();
    if (_matches(uri, filtered)) {
      super.onRequest(options, handler);
      return;
    }
    _requestTime[options] = DateTime.now();
    final bool showData = !_matches(uri, hideRequest);
    final List<String> lines = <String>[
      _start('REQUEST', ''),
      '│ ${options.method} $uri',
      _field('query', options.queryParameters, isPrint: showData, toJson: requestQueryParametersToJson),
      _field('data', options.data, isPrint: showData, toJson: requestDataToJson, responseType: options.responseType),
      _field('headers', _redact(options.headers), isPrint: showData, toJson: requestHeaderToJson),
      _bottom,
    ];
    dioLog(lines.join('\n'));
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final String uri = response.requestOptions.uri.toString();
    if (_matches(uri, filtered)) {
      super.onResponse(response, handler);
      return;
    }
    final bool showData = !_matches(uri, hideResponse);
    final String status = response.statusMessage?.isNotEmpty == true
        ? '${response.statusCode ?? '-'} ${response.statusMessage}'
        : '${response.statusCode ?? '-'}';
    final List<String> details = <String>[status];
    final String duration = _duration(response.requestOptions);
    if (duration.isNotEmpty) details.add(duration);
    final List<String> lines = <String>[
      _start('RESPONSE', details.join(' · ')),
      '│ ${response.requestOptions.method} $uri',
    ];
    if (printResponseHeader) {
      lines.add(_field('headers', _redact(response.headers.map), toJson: requestHeaderToJson));
    }
    lines.add(
      _field(
        'data',
        response.data,
        isPrint: showData,
        toJson: responseToJson,
        responseType: response.requestOptions.responseType,
      ),
    );
    lines.add(_bottom);
    dioLog(lines.join('\n'));
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final String uri = err.requestOptions.uri.toString();
    if (_matches(uri, filtered)) {
      super.onError(err, handler);
      return;
    }
    final bool showData = !_matches(uri, hideResponse);
    final int? statusCode = err.response?.statusCode;
    final String? statusMessage = err.response?.statusMessage;
    final List<String> details = <String>[err.type.name];
    if (statusCode != null) {
      details.add(statusMessage?.isNotEmpty == true ? '$statusCode $statusMessage' : '$statusCode');
    }
    final String duration = _duration(err.requestOptions);
    if (duration.isNotEmpty) details.add(duration);
    final List<String> lines = <String>[
      _start('ERROR', details.join(' · ')),
      '│ ${err.requestOptions.method} $uri',
      _field('error', err.error ?? '-', isPrint: true, toJson: false),
      _field('message', err.message ?? '-', isPrint: true, toJson: false),
    ];
    if (printResponseHeader && err.response != null) {
      lines.add(_field('headers', _redact(err.response!.headers.map), toJson: requestHeaderToJson));
    }
    if (printErrorResponse) {
      lines.add(
        _field(
          'data',
          err.response?.toMap(),
          isPrint: showData,
          toJson: responseToJson,
          responseType: err.response?.requestOptions.responseType,
        ),
      );
    }
    lines.add(_bottom);
    dioLog(lines.join('\n'));
    super.onError(err, handler);
  }

  /// 判断 [uri] 是否命中 [values] 中的任意字符串
  bool _matches(String uri, List<String> values) => values.any((String value) => uri.contains(value));

  /// 按 [redactHeaders] 遮蔽敏感 header
  Map<String, dynamic> _redact(Map<String, dynamic> headers) {
    if (redactHeaders.isEmpty || headers.isEmpty) return headers;
    final Set<String> names = redactHeaders.map((String name) => name.toLowerCase()).toSet();
    return headers.map<String, dynamic>(
      (String key, dynamic value) => MapEntry<String, dynamic>(key, names.contains(key.toLowerCase()) ? '***' : value),
    );
  }

  String _start(String type, String detail) => detail.isEmpty ? '┌ [DIO] $type' : '┌ [DIO] $type · $detail';

  static final String _bottom = '└${'─' * 60}';

  String _field(String label, dynamic data, {bool isPrint = true, bool toJson = false, ResponseType? responseType}) {
    final String value = convertData(data, isPrint: isPrint, toJson: toJson, responseType: responseType).toString();
    final List<String> lines = value.split('\n');
    final String tag = label.padRight(7);
    if (lines.length == 1) return '│ $tag: ${lines.first}';
    return '│ $tag: ${lines.first}\n${lines.skip(1).map((String line) => '│ $line').join('\n')}';
  }

  /// 返回请求耗时，并在读取后清理记录
  String _duration(RequestOptions options) {
    if (!printDuration) return '';
    final DateTime? start = _requestTime[options];
    _requestTime[options] = null;
    if (start == null) return '';
    return '${DateTime.now().difference(start).inMilliseconds} ms';
  }

  /// 把请求/响应数据转成适合打印的文本
  dynamic convertData(dynamic data, {bool isPrint = false, bool toJson = false, ResponseType? responseType}) {
    if (!isPrint) return ' [${data.runtimeType} Hidden] ';
    if (responseType == ResponseType.bytes && !isPrintBytes) {
      return 'ResponseType.bytes: ${data?.runtimeType} [${data is List ? data.length : 0}]';
    }
    if (responseType == ResponseType.stream && data is ResponseBody) {
      return 'ResponseType.stream: ${data.runtimeType} [${data.contentLength}]';
    }
    if (data is FormData) {
      return 'FormData(fields: ${data.fields.length}, files: ${data.files.length})';
    }
    if (toJson && (data is Map || data is List)) {
      try {
        return prettyJson ? const JsonEncoder.withIndent('  ').convert(data) : jsonEncode(data);
      } catch (error) {
        dioLog('LoggerInterceptor to json error: $error');
      }
    }
    return data;
  }
}
