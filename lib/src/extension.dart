import 'package:fl_dio/fl_dio.dart';

extension ExtensionExtendedResponse on ExtendedResponse {
  Map<String, dynamic> toMap() => {
        'headers': headers.map,
        'requestOptions': requestOptions.toMap(),
        'data': data,
        'statusCode': statusCode,
        'statusMessage': statusMessage,
        'extra': extra,
        'realUri': realUri.toMap(),
        'isRedirect': isRedirect,
        'type': type,
        'cookie': cookie,
        'error': error,
        'redirects': redirects
            .map((item) => {
                  'location': item.location,
                  'statusCode': item.statusCode,
                  'method': item.method,
                })
            .toList()
      };
}

extension ExtensionDioException on DioException {
  Map<String, dynamic> toMap() => {
        'error': error,
        'type': type.name,
        'message': message,
        'requestOptions': requestOptions.toMap(),
        'response': response?.toMap(),
        'stackTrace': stackTrace.toString(),
        // 'errorTime': responseTime?.format(DateTimeDist.yearMillisecond),
      };
}

extension ExtensionResponse on Response {
  Map<String, dynamic> toMap() => {
        'headers': headers.map,
        'requestOptions': requestOptions.toMap(),
        'data': data,
        'statusCode': statusCode,
        'statusMessage': statusMessage,
        'extra': extra,
        'realUri': realUri.toMap(),
        'isRedirect': isRedirect,
        'redirects': redirects
            .map((item) => {
                  'location': item.location,
                  'statusCode': item.statusCode,
                  'method': item.method,
                })
            .toList()
      };

  ExtendedResponse<T> toExtendedResponse<T>() => ExtendedResponse<T>(
      requestOptions: requestOptions,
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
      isRedirect: isRedirect,
      redirects: redirects,
      extra: extra,
      headers: headers);
}

extension ExtensionRequestOptions on RequestOptions {
  Map<String, dynamic> toMap() => {
        'baseUrl': baseUrl,
        'path': path,
        'uri': uri.toMap(),
        'method': method,
        'requestHeaders': headers,
        'data': data.toString(),
        'queryParameters': queryParameters,
        'contentType': contentType,
        'receiveTimeout': receiveTimeout?.toString(),
        'sendTimeout': sendTimeout?.toString(),
        'connectTimeout': connectTimeout?.toString(),
        'extra': extra,
        'responseType': responseType.toString(),
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
        'isAbsolute': isAbsolute
      };
}

extension ExtensionUriData on UriData {
  Map<String, dynamic> toMap() => {
        'charset': charset,
        'contentText': contentText,
        'mimeType': mimeType,
        'parameters': parameters,
        'isBase64': isBase64,
        'uri': uri.toMap(),
      };
}

/// int 扩展
extension ExtensionInt on int {
  /// b KB MB GB TB PB
  String toStorageUnit([int round = 2]) {
    int divider = 1024;
    if (this < divider) {
      return '$this B';
    }
    if (this < divider * divider && this % divider == 0) {
      return '${(this / divider).toStringAsFixed(0)} KB';
    }

    if (this < divider * divider) {
      return '${(this / divider).toStringAsFixed(round)} KB';
    }

    if (this < divider * divider * divider && this % (divider * divider) == 0) {
      return '${(this / (divider * divider)).toStringAsFixed(0)} MB';
    }

    if (this < divider * divider * divider) {
      return '${(this / divider / divider).toStringAsFixed(round)} MB';
    }

    if (this < divider * divider * divider * divider &&
        this % (divider * divider * divider) == 0) {
      return '${(this / (divider * divider * divider)).toStringAsFixed(0)} GB';
    }

    if (this < divider * divider * divider * divider) {
      return '${(this / divider / divider / divider).toStringAsFixed(round)} GB';
    }

    if (this < divider * divider * divider * divider * divider &&
        this % (divider / divider / divider / divider) == 0) {
      num r = this / divider / divider / divider / divider;
      return '${r.toStringAsFixed(0)} TB';
    }
    if (this < divider * divider * divider * divider * divider) {
      num r = this / divider / divider / divider / divider;
      return '${r.toStringAsFixed(round)} TB';
    }
    if (this < divider * divider * divider * divider * divider * divider &&
        this % (divider / divider / divider / divider / divider) == 0) {
      num r = this / divider / divider / divider / divider / divider;
      return '${r.toStringAsFixed(0)} PB';
    } else {
      num r = this / divider / divider / divider / divider / divider;
      return '${r.toStringAsFixed(round)} PB';
    }
  }
}
