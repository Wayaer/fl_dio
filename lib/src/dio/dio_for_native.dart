import 'package:dio/io.dart';
import 'package:fl_dio/fl_dio.dart';

/// Create the [ExtendedDio] instance for native platforms.
ExtendedDio createDio([BaseOptions? baseOptions]) =>
    ExtendedDioForNative(baseOptions);

/// Implements features for [ExtendedDio] on native platforms.
class ExtendedDioForNative extends DioForNative with ExtendedDioMixin {
  ExtendedDioForNative([super.baseOptions]);
}
