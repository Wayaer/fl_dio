import 'dart:math' as math;

import 'package:flutter/foundation.dart';

void dioLog(dynamic msg) {
  if (!(kDebugMode || kProfileMode)) return;
  final String message = msg.toString();

  const int limitLength = 800;
  for (final String line in message.split('\n')) {
    int start = 0;
    while (start < line.length) {
      int end = math.min(start + limitLength, line.length);
      // 避免在代理对中间截断
      if (end < line.length) {
        final int unit = line.codeUnitAt(end - 1);
        if (unit >= 0xD800 && unit <= 0xDBFF) end--;
      }
      debugPrint(line.substring(start, end));
      start = end;
    }
    if (line.isEmpty) debugPrint('');
  }
}
