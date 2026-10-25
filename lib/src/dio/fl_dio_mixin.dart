import 'package:fl_dio/fl_dio.dart';

mixin FlDioMixin on DioMixin implements FlDio {
  /// Convenience method to make an HTTP HEAD request.
  @override
  Future<FlResponse<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _handle<T>(
    super.head<T>(path, queryParameters: queryParameters, options: options, data: data, cancelToken: cancelToken),
  );

  /// Convenience method to make an HTTP HEAD request with [Uri].
  @override
  Future<FlResponse<T>> headUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) =>
      _handle<T>(super.headUri<T>(uri, options: options, data: data, cancelToken: cancelToken));

  /// get
  @override
  Future<FlResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.get<T>(
      path,
      options: options,
      data: data,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    ),
  );

  /// getUri
  @override
  Future<FlResponse<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.getUri<T>(uri, options: options, data: data, onReceiveProgress: onReceiveProgress, cancelToken: cancelToken),
  );

  /// post
  @override
  Future<FlResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.post<T>(
      path,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      options: options,
      data: data,
      cancelToken: cancelToken,
    ),
  );

  /// postUri
  @override
  Future<FlResponse<T>> postUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.postUri<T>(
      uri,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: options,
      data: data,
      cancelToken: cancelToken,
    ),
  );

  /// put
  @override
  Future<FlResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.put<T>(
      path,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      options: options,
      data: data,
      cancelToken: cancelToken,
    ),
  );

  /// putUri
  @override
  Future<FlResponse<T>> putUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.putUri<T>(
      uri,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: options,
      data: data,
      cancelToken: cancelToken,
    ),
  );

  /// delete
  @override
  Future<FlResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) => _handle<T>(
    super.delete<T>(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken),
  );

  /// deleteUri
  @override
  Future<FlResponse<T>> deleteUri<T>(Uri uri, {Object? data, Options? options, CancelToken? cancelToken}) =>
      _handle<T>(super.deleteUri<T>(uri, data: data, options: options, cancelToken: cancelToken));

  /// patch
  @override
  Future<FlResponse<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.patch<T>(
      path,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      options: options,
      data: data,
      cancelToken: cancelToken,
    ),
  );

  /// patchUri
  @override
  Future<FlResponse<T>> patchUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.patchUri<T>(
      uri,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
      options: options,
      data: data,
      cancelToken: cancelToken,
    ),
  );

  /// download
  @override
  Future<FlResponse> download(
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
  }) => _handle(
    super.download(
      urlPath,
      savePath,
      data: data,
      queryParameters: queryParameters,
      options: options,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      fileAccessMode: fileAccessMode,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  /// downloadUri
  @override
  Future<FlResponse> downloadUri(
    Uri uri,
    dynamic savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    FileAccessMode fileAccessMode = FileAccessMode.write,
    Object? data,
    Options? options,
  }) => _handle(
    super.downloadUri(
      uri,
      savePath,
      data: data,
      options: options,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      fileAccessMode: fileAccessMode,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  /// request
  @override
  Future<FlResponse<T>> request<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.request<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  /// requestUri
  @override
  Future<FlResponse<T>> requestUri<T>(
    Uri uri, {
    Object? data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) => _handle<T>(
    super.requestUri<T>(
      uri,
      data: data,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    ),
  );

  /// The eventual method to submit requests. All callers for requests should
  /// eventually go through this method.
  @override
  Future<FlResponse<T>> fetch<T>(RequestOptions requestOptions) => _handle(super.fetch(requestOptions));

  /// 返回同样是 [FlDio] 的克隆，保留不抛异常的行为
  @override
  FlDio clone({
    BaseOptions? options,
    Interceptors? interceptors,
    HttpClientAdapter? httpClientAdapter,
    Transformer? transformer,
  }) {
    final FlDio dio = FlDio(options ?? this.options);
    dio.interceptors.removeImplyContentTypeInterceptor();
    dio.interceptors.addAll(interceptors ?? this.interceptors);
    dio.httpClientAdapter = httpClientAdapter ?? this.httpClientAdapter;
    dio.transformer = transformer ?? this.transformer;
    return dio;
  }

  Future<FlResponse<T>> _handle<T>(Future<Response<T>> call) async {
    late FlResponse<T> flResponse;
    try {
      final res = await call;
      if (res is! FlResponse<T>) {
        flResponse = res.toFlResponse<T>();
      } else {
        flResponse = res;
      }
    } on DioException catch (exception) {
      flResponse = FlResponse.mergeDioException<T>(exception);
    } catch (exception) {
      flResponse = FlResponse.generalFlResponse<T>(exception: exception);
    }
    return flResponse;
  }
}
