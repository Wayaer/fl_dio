import 'dart:io';

import 'package:dio/io.dart';
import 'package:fl_dio/fl_dio.dart';

/// Create the [IOHttpClientAdapter] instance for native platforms.
HttpClientAdapter createDioAdapter({
  /// When this callback is set, [Dio] will call it every
  /// time it needs a [HttpClient].
  CreateHttpClientForNative? createHttpClient,

  /// Allows the user to decide if the response certificate is good.
  /// If this function is missing, then the certificate is allowed.
  /// This method is called only if both the [SecurityContext] and
  /// [badCertificateCallback] accept the certificate chain. Those
  /// methods evaluate the root or intermediate certificate, while
  /// [validateCertificate] evaluates the leaf certificate.
  ValidateCertificateForNative? validateCertificate,

  /// No practical significance
  bool withCredentials = false,
}) =>
    IOHttpClientAdapter(
        createHttpClient: createHttpClient,
        validateCertificate: validateCertificate);
