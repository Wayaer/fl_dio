import 'package:fl_dio/fl_dio.dart';

mixin ExtendedDioMixin on DioMixin implements ExtendedDio {
  /// Convenience method to make an HTTP HEAD request.
  @override
  Future<ExtendedResponse<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _handle<T>(super.head<T>(path,
          queryParameters: queryParameters,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// Convenience method to make an HTTP HEAD request with [Uri].
  @override
  Future<ExtendedResponse<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _handle<T>(super.headUri<T>(uri,
          options: options, data: data, cancelToken: cancelToken));

  /// get
  @override
  Future<ExtendedResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.get<T>(path,
          options: options,
          data: data,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          cancelToken: cancelToken));

  /// getUri
  @override
  Future<ExtendedResponse<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.getUri<T>(uri,
          options: options,
          data: data,
          onReceiveProgress: onReceiveProgress,
          cancelToken: cancelToken));

  /// post
  @override
  Future<ExtendedResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.post<T>(path,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// postUri
  @override
  Future<ExtendedResponse<T>> postUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.postUri<T>(uri,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// put
  @override
  Future<ExtendedResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.put<T>(path,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// putUri
  @override
  Future<ExtendedResponse<T>> putUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.putUri<T>(uri,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// delete
  @override
  Future<ExtendedResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _handle<T>(super.delete<T>(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken));

  /// deleteUri
  @override
  Future<ExtendedResponse<T>> deleteUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) =>
      _handle<T>(super.deleteUri<T>(uri,
          data: data, options: options, cancelToken: cancelToken));

  /// patch
  @override
  Future<ExtendedResponse<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.patch<T>(path,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          queryParameters: queryParameters,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// patchUri
  @override
  Future<ExtendedResponse<T>> patchUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.patchUri<T>(uri,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
          options: options,
          data: data,
          cancelToken: cancelToken));

  /// download
  @override
  Future<ExtendedResponse> download(
    String urlPath,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    Object? data,
    Options? options,
  }) =>
      _handle(super.download(urlPath, savePath,
          data: data,
          queryParameters: queryParameters,
          options: options,
          deleteOnError: deleteOnError,
          lengthHeader: lengthHeader,
          fileAccessMode: fileAccessMode,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress));

  /// downloadUri
  @override
  Future<ExtendedResponse> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    Object? data,
    Options? options,
  }) =>
      _handle(super.downloadUri(uri, savePath,
          data: data,
          options: options,
          deleteOnError: deleteOnError,
          lengthHeader: lengthHeader,
          fileAccessMode: fileAccessMode,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress));

  /// request
  @override
  Future<ExtendedResponse<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.request<T>(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress));

  /// requestUri
  @override
  Future<ExtendedResponse<T>> requestUri<T>(
    Uri uri, {
    Object? data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) =>
      _handle<T>(super.requestUri<T>(uri,
          data: data,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress));

  /// The eventual method to submit requests. All callers for requests should
  /// eventually go through this method.
  @override
  Future<ExtendedResponse<T>> fetch<T>(RequestOptions requestOptions) =>
      _handle(super.fetch(requestOptions));

  Future<ExtendedResponse<T>> _handle<T>(Future<Response<T>> call) async {
    late ExtendedResponse<T> extendedResponse;
    try {
      final res = await call;
      if (res is! ExtendedResponse<T>) {
        extendedResponse = res.toExtendedResponse<T>();
      } else {
        extendedResponse = res;
      }
    } on DioException catch (exception) {
      extendedResponse = ExtendedResponse.mergeDioException<T>(exception);
    } catch (exception) {
      extendedResponse =
          ExtendedResponse.generalExtendedResponse<T>(exception: exception);
    }
    return extendedResponse;
  }
}
