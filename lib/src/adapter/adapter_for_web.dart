import 'package:dio_web_adapter/dio_web_adapter.dart';
import 'package:fl_dio/fl_dio.dart';

/// Create the [HttpClientAdapter] instance for Web platforms.
HttpClientAdapter createDioAdapter({
  /// Whether to send credentials such as cookies or authorization headers for
  /// cross-site requests.
  ///
  /// Defaults to `false`.
  ///
  /// You can also override this value using `Options.extra['withCredentials']`
  /// for each request.
  bool withCredentials = false,

  /// No practical significance
  CreateHttpClientForNative? createHttpClient,

  /// No practical significance
  ValidateCertificateForNative? validateCertificate,
}) =>
    BrowserHttpClientAdapter(withCredentials: withCredentials);

class HttpClient {}

class X509Certificate {}
