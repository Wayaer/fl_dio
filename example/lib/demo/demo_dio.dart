import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/material.dart';

/// 全局 Navigator，供 DebuggerInterceptor 使用。
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 全局 ScaffoldMessenger，供 JsonParse 的复制提示使用。
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// 示例默认的 dio 实例。
final FlDio demoDio = FlDio(
  BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ),
);

void setupDemoDio() {
  DebuggerInterceptorHelper().navigatorKey = navigatorKey;

  JsonParse.toastBuilder = (String content) => showMessage('已复制：$content');

  // 发布版默认关闭 DebuggerInterceptor，示例需要始终展示调试面板
  demoDio.interceptors.addAll([LoggerInterceptor(), DebuggerInterceptor(enabled: true)]);

  demoDio.httpClientAdapter = UniversalHttpClientAdapter().create();
}

/// 在任意页面显示一条简短提示。
void showMessage(String message) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(content: Text(message), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
  );
}

/// 统一以底部弹层展示 [FlResponse]，内部复用 JsonParse。
Future<void> showFlResponse(BuildContext context, FlResponse<dynamic> response) {
  final double height = MediaQuery.sizeOf(context).height * 0.78;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (BuildContext context) {
      final ColorScheme colors = Theme.of(context).colorScheme;
      return SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _ResponseHeader(response: response),
            ),
            const Divider(height: 1),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Padding(padding: const EdgeInsets.all(12), child: JsonParse(response.toMap())),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// 页面通用的提示卡片。
class DemoHint extends StatelessWidget {
  const DemoHint(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      color: colors.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.onSecondaryContainer)),
      ),
    );
  }
}

class _ResponseHeader extends StatelessWidget {
  const _ResponseHeader({required this.response});

  final FlResponse<dynamic> response;

  @override
  Widget build(BuildContext context) {
    final DioException? error = response.exception is DioException ? response.exception as DioException : null;
    final int? statusCode = response.statusCode ?? error?.response?.statusCode;
    final bool success = response.exception == null;
    final ThemeData theme = Theme.of(context);
    final String title = success
        ? '请求成功${statusCode == null ? '' : ' · HTTP $statusCode'}'
        : '请求失败${statusCode == null ? '' : ' · HTTP $statusCode'}';
    final String detail = success
        ? response.requestOptions.uri.toString()
        : '${response.type?.name ?? 'unknown'}'
              '${response.exception == null ? '' : '\n${response.exception}'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(success ? Icons.check_circle : Icons.error, color: success ? Colors.green : theme.colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
            Text(response.requestOptions.method, style: theme.textTheme.labelLarge),
          ],
        ),
        const SizedBox(height: 6),
        Text(detail, maxLines: 3, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
