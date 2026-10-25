import 'package:dio/browser.dart';
import 'package:fl_dio/fl_dio.dart';

/// Create the [FlDio] instance for Web platforms.
FlDio createDio([BaseOptions? options]) => FlDioForBrowser(options);

class FlDioForBrowser extends DioForBrowser with FlDioMixin {
  FlDioForBrowser([super.baseOptions]);
}
