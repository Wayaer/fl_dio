import 'package:dio/dio.dart';

/// 扩展 header
typedef ValueCallbackExtraHeader = Map<String, dynamic>? Function(
    Uri url, Map<String, dynamic> headers);

/// 扩展 params
typedef ValueCallbackExtraParams = Map<String, dynamic>? Function(
    Uri uri, Map<String, dynamic> params);

/// 扩展 data
typedef ValueCallbackExtraData = dynamic Function(Uri uri, dynamic data);

/// 扩展 path
typedef ValueCallbackExtraPath = String? Function(Uri uri);

class ExtraParamsInterceptor extends InterceptorsWrapper {
  ExtraParamsInterceptor({
    this.onExtraHeader,
    this.onExtraData,
    this.onExtraParams,
    this.onExtraPath,
  });

  ///  扩展 header
  ValueCallbackExtraHeader? onExtraHeader;

  /// 扩展 data
  ValueCallbackExtraData? onExtraData;

  /// 扩展 params
  ValueCallbackExtraParams? onExtraParams;

  /// 扩展 path
  ValueCallbackExtraPath? onExtraPath;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (onExtraHeader != null) {
      final header = onExtraHeader!(options.uri, options.headers);
      if (header != null) options.headers = header;
    }

    if (onExtraParams != null) {
      final params = onExtraParams!(options.uri, options.queryParameters);
      if (params != null) options.queryParameters = params;
    }

    if (onExtraPath != null) {
      final path = onExtraPath!(options.uri);
      if (path != null) options.path = path;
    }

    if (onExtraData != null) {
      final data = onExtraData!(options.uri, options.data);
      if (data != null) options.data = data;
    }
    super.onRequest(options, handler);
  }
}
