import 'dart:convert';
import 'dart:typed_data';

import 'package:fl_dio/fl_dio.dart';

extension ExtensionFlResponse on FlResponse {
  Map<String, dynamic> toMap() => {
    'headers': headers.map,
    'requestOptions': requestOptions.toMap(),
    'data': _dataToMap(data),
    'statusCode': statusCode,
    'statusMessage': statusMessage,
    'extra': extra,
    'realUri': realUri.toMap(),
    'isRedirect': isRedirect,
    'type': type?.name,
    'cookie': cookie,
    'exception': exception is DioException ? (exception as DioException).toMap() : exception,
    'redirects': redirects
        .map((item) => {'location': item.location, 'statusCode': item.statusCode, 'method': item.method})
        .toList(),
  };
}

/// 把响应数据转换为适合展示/序列化的形式：解析 JSON 字符串，字节数据输出摘要
dynamic _dataToMap(dynamic data) {
  if (data is String) {
    try {
      return jsonDecode(data);
    } catch (e) {
      dioLog('ExtensionResponse dataToMap:$e');
    }
    return data;
  }
  if (data is TypedData) return '<${data.runtimeType}>[${data.lengthInBytes}]';
  return data;
}

extension ExtensionDioException on DioException {
  Map<String, dynamic> toMap() => {
    'error': error,
    'type': type.name,
    'message': message,
    'requestOptions': requestOptions.toMap(),
    'response': response?.toMap(),
    'stackTrace': stackTrace.toString(),
  };
}

extension ExtensionResponse on Response {
  Map<String, dynamic> toMap() => {
    'headers': headers.map,
    'requestOptions': requestOptions.toMap(),
    'data': dataToMap(),
    'statusCode': statusCode,
    'statusMessage': statusMessage,
    'extra': extra,
    'realUri': realUri.toMap(),
    'isRedirect': isRedirect,
    'redirects': redirects
        .map((item) => {'location': item.location, 'statusCode': item.statusCode, 'method': item.method})
        .toList(),
  };

  dynamic dataToMap() => _dataToMap(data);

  FlResponse<T> toFlResponse<T>() => FlResponse<T>(
    requestOptions: requestOptions,
    data: data,
    statusCode: statusCode,
    statusMessage: statusMessage,
    isRedirect: isRedirect,
    redirects: redirects,
    extra: extra,
    headers: headers,
    cookie: headers['set-cookie']?.toList(),
  );
}

extension ExtensionRequestOptions on RequestOptions {
  Map<String, dynamic> toMap() => {
    'baseUrl': baseUrl,
    'path': path,
    'uri': uri.toMap(),
    'method': method,
    'requestHeaders': headers,
    'data': data is Map || data is List ? data : data?.toString(),
    'queryParameters': queryParameters,
    'contentType': contentType,
    'receiveTimeout': receiveTimeout?.inMilliseconds,
    'sendTimeout': sendTimeout?.inMilliseconds,
    'connectTimeout': connectTimeout?.inMilliseconds,
    'extra': extra,
    'responseType': responseType.name,
    'receiveDataWhenStatusError': receiveDataWhenStatusError,
    'followRedirects': followRedirects,
    'maxRedirects': maxRedirects,
  };
}

extension ExtensionUri on Uri {
  Map<String, dynamic> toMap() => {
    'path': path,
    'pathSegments': pathSegments,
    'data': data?.toMap(),
    'host': host,
    'port': port,
    'query': query,
    'scheme': scheme,
    'userInfo': userInfo,
    'queryParameters': queryParameters,
    'queryParametersAll': queryParametersAll,
    'authority': authority,
    'fragment': fragment,
    'hasAbsolutePath': hasAbsolutePath,
    'isAbsolute': isAbsolute,
  };
}

extension ExtensionUriData on UriData {
  Map<String, dynamic> toMap() => {
    'charset': charset,
    'contentText': contentText,
    'mimeType': mimeType,
    'parameters': parameters,
    'isBase64': isBase64,
    'uri': uri.toString(),
  };
}

/// int 扩展
extension ExtensionIntToStorageUnit on int {
  /// b KB MB GB TB PB，默认保留 [round] 位小数，整除时省略小数
  String toStorageUnit([int round = 2]) {
    if (this < 1024) return '$this B';
    const List<String> units = <String>['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    double value = toDouble();
    int unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    final bool isInteger = value == value.roundToDouble();
    return '${value.toStringAsFixed(isInteger ? 0 : round)} ${units[unit]}';
  }
}
