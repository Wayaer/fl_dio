import 'package:dio/dio.dart';
import 'adapter_for_native.dart' if (dart.library.html) 'adapter_for_web.dart';
import 'dart:io' if (dart.library.html) 'adapter_for_web.dart';

/// The signature of [IOHttpClientAdapter.createHttpClient].
/// Can be used to provide a custom [HttpClient] for Dio.
typedef CreateHttpClientForNative = HttpClient Function();

/// The signature of [IOHttpClientAdapter.validateCertificate].
typedef ValidateCertificateForNative = bool Function(
  X509Certificate? certificate,
  String host,
  int port,
);

/// Using [BrowserHttpClientAdapter] on the web
/// Using [IOHttpClientAdapter] on native
class UniversalHttpClientAdapter {
  UniversalHttpClientAdapter(
      {this.withCredentials = false,
      this.createHttpClient,
      this.validateCertificate});

  /// for web
  final bool withCredentials;

  /// for native
  final CreateHttpClientForNative? createHttpClient;

  /// for native
  final ValidateCertificateForNative? validateCertificate;

  HttpClientAdapter create() => createDioAdapter(
      withCredentials: withCredentials,
      createHttpClient: createHttpClient,
      validateCertificate: validateCertificate);
}
