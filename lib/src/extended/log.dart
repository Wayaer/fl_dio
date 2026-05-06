import 'package:flutter/foundation.dart';

void dioLog(dynamic msg) {
  if (!(kDebugMode || kProfileMode)) return;
  final String message = msg.toString();

  const int limitLength = 800;
  if (message.length < limitLength) {
    debugPrint('$msg');
  } else {
    final StringBuffer outStr = StringBuffer();
    for (int index = 0; index < message.length; index++) {
      outStr.write(message[index]);
      if (index % limitLength == 0 && index != 0) {
        debugPrint(outStr.toString());
        outStr.clear();
        final int lastIndex = index + 1;
        if (message.length - lastIndex < limitLength) {
          final String remainderStr =
              message.substring(lastIndex, message.length);
          debugPrint(remainderStr);
          break;
        }
      }
    }
  }
}
