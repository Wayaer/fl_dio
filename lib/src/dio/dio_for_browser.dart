import 'package:dio/browser.dart';
import 'package:fl_dio/fl_dio.dart';

/// Create the [ExtendedDio] instance for Web platforms.
ExtendedDio createDio([BaseOptions? options]) => ExtendedDioForBrowser(options);

class ExtendedDioForBrowser extends DioForBrowser with ExtendedDioMixin {
  ExtendedDioForBrowser([super.baseOptions]);
}
