import 'package:fl_dio/fl_dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExtensionIntToStorageUnit', () {
    test('小于 1024 时输出 B', () {
      expect(0.toStorageUnit(), '0 B');
      expect(1023.toStorageUnit(), '1023 B');
      expect((-1024).toStorageUnit(), '-1024 B');
    });

    test('各单位的整数结果不带小数', () {
      expect(1024.toStorageUnit(), '1 KB');
      expect((1024 * 1024).toStorageUnit(), '1 MB');
      expect((1024 * 1024 * 1024).toStorageUnit(), '1 GB');
      expect((1024 * 1024 * 1024 * 1024).toStorageUnit(), '1 TB');
      expect((1024 * 1024 * 1024 * 1024 * 1024).toStorageUnit(), '1 PB');
    });

    test('非整数结果按 round 保留小数', () {
      expect(1536.toStorageUnit(), '1.50 KB');
      expect(1100.toStorageUnit(), '1.07 KB');
      expect(1100.toStorageUnit(0), '1 KB');
      expect((1024 * 1024 * 3 ~/ 2).toStorageUnit(), '1.50 MB');
    });

    test('超出 PB 不再进位', () {
      expect((1024 * 1024 * 1024 * 1024 * 1024 * 1024).toStorageUnit(), '1024 PB');
    });
  });
}
