import 'package:fl_dio/fl_dio.dart';

import 'dio/dio_for_native.dart'
    if (dart.library.html) 'dio/dio_for_browser.dart';

abstract class ExtendedDio implements Dio {
  factory ExtendedDio([BaseOptions? options]) => createDio(options);

  /// Convenience method to make an HTTP HEAD request.  @override
  @override
  Future<ExtendedResponse<T>> head<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Convenience method to make an HTTP HEAD request with [Uri].
  @override
  Future<ExtendedResponse<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Convenience method to make an HTTP GET request.
  @override
  Future<ExtendedResponse<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP GET request with [Uri].
  @override
  Future<ExtendedResponse<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP POST request.
  @override
  Future<ExtendedResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP POST request with [Uri] .
  @override
  Future<ExtendedResponse<T>> postUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PUT request .
  @override
  Future<ExtendedResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PUT request with [Uri] .
  @override
  Future<ExtendedResponse<T>> putUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PATCH request .
  @override
  Future<ExtendedResponse<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP PATCH request with [Uri] .
  @override
  Future<ExtendedResponse<T>> patchUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Convenience method to make an HTTP DELETE request .
  @override
  Future<ExtendedResponse<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  });

  /// Convenience method to make an HTTP DELETE request with [Uri] .
  @override
  Future<ExtendedResponse<T>> deleteUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  });

  /// {@template dio.Dio.download}
  /// Download the file and save it in local. The default http method is "GET",
  /// you can custom it by [Options.method].
  ///
  /// [urlPath] is the file url.
  ///
  /// The file will be saved to the path specified by [savePath].
  /// The following two types are accepted:
  /// 1. `String`: A path, eg "xs.jpg"
  /// 2. `FutureOr<String> Function(Headers headers)`, for example:
  ///    ```dart
  ///    await dio.download(
  ///      url,
  ///      (Headers headers) {
  ///        // Extra info: redirect counts
  ///        print(headers.value('redirects'));
  ///        // Extra info: real uri
  ///        print(headers.value('uri'));
  ///        // ...
  ///        return (await getTemporaryDirectory()).path + 'file_name';
  ///      },
  ///    );
  ///    ```
  ///
  /// [onReceiveProgress] is the callback to listen downloading progress.
  /// Please refer to [ProgressCallback].
  ///
  /// [deleteOnError] whether delete the file when error occurs.
  /// The default value is [true].
  ///
  /// [lengthHeader] : The real size of original file (not compressed).
  /// When file is compressed:
  /// 1. If this value is 'content-length', the `total` argument of
  ///    [onReceiveProgress] will be -1.
  /// 2. If this value is not 'content-length', maybe a custom header indicates
  ///    the original file size, the `total` argument of [onReceiveProgress]
  ///    will be this header value.
  ///
  /// You can also disable the compression by specifying the 'accept-encoding'
  /// header value as '*' to assure the value of `total` argument of
  /// [onReceiveProgress] is not -1. For example:
  ///
  /// ```dart
  /// await dio.download(
  ///   url,
  ///   (await getTemporaryDirectory()).path + 'flutter.svg',
  ///   options: Options(
  ///     headers: {HttpHeaders.acceptEncodingHeader: '*'}, // Disable gzip
  ///   ),
  ///   onReceiveProgress: (received, total) {
  ///     if (total <= 0) return;
  ///     print('percentage: ${(received / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  /// {@endtemplate}
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
  });

  /// {@macro dio.Dio.download}
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
      download(uri.toString(), savePath,
          onReceiveProgress: onReceiveProgress,
          lengthHeader: lengthHeader,
          fileAccessMode: fileAccessMode,
          deleteOnError: deleteOnError,
          cancelToken: cancelToken,
          data: data,
          options: options);

  /// Make HTTP request with options .
  @override
  Future<ExtendedResponse<T>> request<T>(
    String url, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// Make http request with options with [Uri] .
  @override
  Future<ExtendedResponse<T>> requestUri<T>(
    Uri uri, {
    Object? data,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  });

  /// The eventual method to submit requests. All callers for requests should
  /// eventually go through this method .
  @override
  Future<ExtendedResponse<T>> fetch<T>(RequestOptions requestOptions);
}
