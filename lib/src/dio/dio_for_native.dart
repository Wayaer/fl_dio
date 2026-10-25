import 'package:dio/io.dart';
import 'package:fl_dio/fl_dio.dart';

/// Create the [FlDio] instance for native platforms.
FlDio createDio([BaseOptions? baseOptions]) => FlDioForNative(baseOptions);

/// Implements features for [FlDio] on native platforms.
class FlDioForNative extends DioForNative with FlDioMixin {
  FlDioForNative([super.baseOptions]);
}
