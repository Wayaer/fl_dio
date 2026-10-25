import 'dart:convert';

import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _ValueNotifiers<T> extends ValueNotifier<T> {
  _ValueNotifiers(super.value);

  void notify() {
    notifyListeners();
  }
}

class DebuggerInterceptorDataModel {
  DebuggerInterceptorDataModel({
    this.requestOptions,
    this.response,
    this.error,
    this.requestTime,
    this.responseTime,
    this.errorTime,
  });

  RequestOptions? requestOptions;

  Response<dynamic>? response;

  DioException? error;

  DateTime? requestTime;

  DateTime? responseTime;

  DateTime? errorTime;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'requestOptions': requestOptionsToMap(),
    'response': responseToMap(),
    'error': errorToMap(),
  };

  Map<String, dynamic> requestOptionsToMap() => <String, dynamic>{
    ...requestOptions?.toMap() ?? <String, dynamic>{},
    'requestTime': requestTime?.toString(),
  };

  Map<String, dynamic> responseToMap() => <String, dynamic>{
    ...response?.toMap() ?? <String, dynamic>{},
    'responseTime': responseTime?.toString(),
  };

  Map<String, dynamic> errorToMap() => <String, dynamic>{
    ...error?.toMap() ?? <String, dynamic>{},
    'errorTime': errorTime?.toString(),
  };
}

/// 记录请求并在 App 内提供悬浮调试入口。
class DebuggerInterceptor extends InterceptorsWrapper {
  DebuggerInterceptor({this.enabled = kDebugMode || kProfileMode});

  /// 是否记录请求；默认仅在 debug / profile 模式下启用，release 下不产生任何开销
  final bool enabled;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!enabled) {
      super.onRequest(options, handler);
      return;
    }
    final DebuggerInterceptorHelper helper = DebuggerInterceptorHelper();
    final DebuggerInterceptorDataModel model = DebuggerInterceptorDataModel(
      requestOptions: options,
      requestTime: DateTime.now(),
    );
    final Map<RequestOptions, DebuggerInterceptorDataModel> data = helper._debugData.value;
    data[options] = model;
    _evict(helper, data);
    helper._debugData.notify();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!enabled) {
      super.onResponse(response, handler);
      return;
    }
    final DebuggerInterceptorHelper helper = DebuggerInterceptorHelper();
    final DebuggerInterceptorDataModel? model = helper._debugData.value[response.requestOptions];
    if (model != null) {
      model.response = response;
      model.responseTime = DateTime.now();
      helper._debugData.notify();
    }
    helper.show();
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!enabled) {
      super.onError(err, handler);
      return;
    }
    final DebuggerInterceptorHelper helper = DebuggerInterceptorHelper();
    final DebuggerInterceptorDataModel? model = helper._debugData.value[err.requestOptions];
    if (model != null) {
      model.error = err;
      model.errorTime = DateTime.now();
      helper._debugData.notify();
    }
    helper.show();
    super.onError(err, handler);
  }

  /// 超出 [DebuggerInterceptorHelper.maxRecords] 时，优先淘汰已完成的记录
  void _evict(DebuggerInterceptorHelper helper, Map<RequestOptions, DebuggerInterceptorDataModel> data) {
    final int maxRecords = helper.maxRecords;
    if (maxRecords <= 0) return;
    while (data.length > maxRecords) {
      RequestOptions? completed;
      for (final MapEntry<RequestOptions, DebuggerInterceptorDataModel> entry in data.entries) {
        if (entry.value.response != null || entry.value.error != null) {
          completed = entry.key;
          break;
        }
      }
      data.remove(completed ?? data.keys.first);
    }
  }
}

class DebuggerInterceptorHelper {
  factory DebuggerInterceptorHelper() => _instance;

  DebuggerInterceptorHelper._();

  static final DebuggerInterceptorHelper _instance = DebuggerInterceptorHelper._();

  static DebuggerInterceptorHelper get instance => _instance;

  GlobalKey<NavigatorState>? navigatorKey;

  OverlayEntry? _overlayEntry;

  /// 最多保留的请求记录条数，超出后移除最早的记录
  int maxRecords = 100;

  final _ValueNotifiers<Map<RequestOptions, DebuggerInterceptorDataModel>> _debugData = _ValueNotifiers(
    <RequestOptions, DebuggerInterceptorDataModel>{},
  );

  void show() {
    if (_overlayEntry != null) return;
    _overlayEntry = _showOverlay(_DebuggerIcon(show: showDebugger, hide: hide));
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> showDebugger() async {
    final BuildContext? context = navigatorKey?.currentContext;
    if (context == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DebuggerList(),
    );
  }

  OverlayEntry? _showOverlay(Widget widget) {
    final OverlayState? overlay = navigatorKey?.currentState?.overlay;
    if (overlay == null) return null;
    final OverlayEntry entry = OverlayEntry(builder: (_) => widget);
    overlay.insert(entry);
    return entry;
  }

  void clear() {
    _debugData.value = <RequestOptions, DebuggerInterceptorDataModel>{};
  }
}

class _DebuggerList extends StatelessWidget {
  const _DebuggerList();

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: ValueListenableBuilder<Map<RequestOptions, DebuggerInterceptorDataModel>>(
        valueListenable: DebuggerInterceptorHelper()._debugData,
        builder: (BuildContext context, Map<RequestOptions, DebuggerInterceptorDataModel> data, _) {
          final List<MapEntry<RequestOptions, DebuggerInterceptorDataModel>> entries = data.entries
              .toList()
              .reversed
              .toList();
          return Column(
            children: <Widget>[
              _Toolbar(
                title: '请求记录',
                count: entries.length,
                onDelete: entries.isEmpty ? null : DebuggerInterceptorHelper().clear,
              ),
              if (entries.isEmpty)
                const Expanded(child: _EmptyState())
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: entries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (BuildContext context, int index) {
                      final MapEntry<RequestOptions, DebuggerInterceptorDataModel> entry = entries[index];
                      return _HttpCard(entry.value, onTap: () => _openDetail(context, entry.key, entry.value));
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, RequestOptions requestOptions, DebuggerInterceptorDataModel model) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DebuggerDetail(requestOptions, model),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final TextStyle? hintStyle = Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.outline);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.inbox_outlined, size: 44, color: colors.outline),
          const SizedBox(height: 10),
          Text('暂无请求记录', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.outline)),
          const SizedBox(height: 4),
          Text('发出请求后会在这里显示', style: hintStyle),
        ],
      ),
    );
  }
}

class _DebuggerIcon extends StatefulWidget {
  const _DebuggerIcon({required this.show, this.hide});

  final void Function()? hide;
  final Future<void> Function() show;

  @override
  State<_DebuggerIcon> createState() => _DebuggerIconState();
}

class _DebuggerIconState extends State<_DebuggerIcon> {
  bool hasWindows = false;
  Offset _offset = const Offset(60, 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _offset = Offset(60, MediaQuery.paddingOf(context).top + 8);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Stack(
      children: <Widget>[
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            onTap: _show,
            onDoubleTap: widget.hide,
            onPanStart: (DragStartDetails details) => _update(details.globalPosition),
            onPanUpdate: (DragUpdateDetails details) => _update(details.globalPosition),
            child: ValueListenableBuilder<Map<RequestOptions, DebuggerInterceptorDataModel>>(
              valueListenable: DebuggerInterceptorHelper()._debugData,
              builder: (BuildContext context, Map<RequestOptions, DebuggerInterceptorDataModel> data, _) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(Icons.bug_report_rounded, size: 22, color: colors.onPrimary),
                    ),
                    if (data.isNotEmpty)
                      Positioned(
                        right: -3,
                        top: -3,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(10)),
                          child: Text(
                            data.length > 99 ? '99+' : '${data.length}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.onError, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _show() async {
    if (hasWindows) {
      Navigator.of(context).maybePop();
    } else {
      hasWindows = true;
      await widget.show();
      hasWindows = false;
    }
  }

  void _update(Offset position) {
    final Size size = MediaQuery.sizeOf(context);
    final EdgeInsets padding = MediaQuery.paddingOf(context);
    if (position.dx > 0 &&
        position.dx < size.width - 24 &&
        position.dy > padding.top &&
        position.dy < size.height - padding.bottom - 24) {
      setState(() {
        _offset = Offset(position.dx - 18, position.dy - 24);
      });
    }
  }
}

class _HttpCard extends StatelessWidget {
  const _HttpCard(this.model, {this.onTap});

  final DebuggerInterceptorDataModel model;

  final GestureTapCallback? onTap;

  bool get _isPending => model.response == null && model.error == null;

  RequestOptions? get _options => model.requestOptions;

  int? get _statusCode => model.response?.statusCode ?? model.error?.response?.statusCode;

  String get _method => _options?.method ?? 'UNKNOWN';

  bool get _isHttps => _options?.uri.scheme == 'https';

  String get _host {
    final String host = _options?.uri.host ?? '';
    return host.isEmpty ? (_options?.baseUrl ?? 'unknown') : host;
  }

  String get _path {
    final Uri? uri = _options?.uri;
    if (uri == null) return 'unknown';
    final String path = uri.path.isEmpty ? '/' : uri.path;
    return uri.query.isEmpty ? path : '$path?${uri.query}';
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final Color statusColor = _statusColor(_statusCode);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: () => Clipboard.setData(ClipboardData(text: model.toMap().toString())),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _Badge(text: _method, color: _methodColor(_method)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_isPending)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                    )
                  else
                    _Badge(text: '${_statusCode ?? 'N/A'}', color: statusColor),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: <Widget>[
                  Icon(
                    _isHttps ? Icons.lock_outline : Icons.lock_open_outlined,
                    size: 14,
                    color: _isHttps ? Colors.green : colors.outline,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(_host, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: <Widget>[
                  Icon(Icons.schedule, size: 13, color: colors.outline),
                  const SizedBox(width: 3),
                  Text(_formatTime(model.requestTime), style: theme.textTheme.labelSmall),
                  const Spacer(),
                  Text(_sizeText(model.response?.data), style: theme.textTheme.labelSmall),
                  const SizedBox(width: 12),
                  Text(_durationText(), style: theme.textTheme.labelSmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? time) {
    if (time == null) return '--:--:--';
    final String text = time.toIso8601String();
    return text.length >= 23 ? text.substring(11, 23) : text;
  }

  String _sizeText(dynamic data) {
    if (data == null) return '-';
    final int length = data is List<int> ? data.length : utf8.encode(data.toString()).length;
    return length.toStorageUnit();
  }

  String _durationText() {
    final DateTime? start = model.requestTime;
    final DateTime? end = model.responseTime ?? model.errorTime;
    if (start == null || end == null) return _isPending ? 'pending' : '-';
    return '${end.difference(start).inMilliseconds} ms';
  }

  Color _methodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green.shade600;
      case 'POST':
        return Colors.blue.shade600;
      case 'PUT':
        return Colors.orange.shade700;
      case 'PATCH':
        return Colors.purple.shade500;
      case 'DELETE':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _statusColor(int? code) {
    if (code == null) return Colors.grey.shade600;
    if (code >= 200 && code < 300) return Colors.green.shade600;
    if (code >= 300 && code < 400) return Colors.blue.shade600;
    if (code >= 400 && code < 500) return Colors.orange.shade700;
    return Colors.red.shade600;
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _DebuggerDetail extends StatelessWidget {
  const _DebuggerDetail(this.requestOptions, this.model);

  final DebuggerInterceptorDataModel model;
  final RequestOptions requestOptions;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Material(
      type: MaterialType.card,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: <Widget>[
            _Toolbar(
              title: '请求详情',
              onCopy: () => Clipboard.setData(ClipboardData(text: model.toMap().toString())),
              onDelete: () => _delete(context),
            ),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _HttpCard(model)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicator: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(9)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
                  labelColor: colors.onSecondaryContainer,
                  unselectedLabelColor: colors.onSurfaceVariant,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  tabs: const <Widget>[
                    Tab(text: '请求'),
                    Tab(text: '响应'),
                    Tab(text: '错误'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  _JsonCard(model.requestOptionsToMap()),
                  _JsonCard(model.responseToMap()),
                  _JsonCard(model.errorToMap()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _delete(BuildContext context) {
    Navigator.of(context).maybePop();
    final Map<RequestOptions, DebuggerInterceptorDataModel> data = Map<RequestOptions, DebuggerInterceptorDataModel>.of(
      DebuggerInterceptorHelper()._debugData.value,
    );
    data.remove(requestOptions);
    DebuggerInterceptorHelper()._debugData.value = data;
  }
}

class _JsonCard extends StatelessWidget {
  const _JsonCard(this.data);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Padding(padding: const EdgeInsets.all(12), child: JsonParse(data)),
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({this.title, this.count, this.onCopy, this.onDelete});

  final String? title;
  final int? count;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 6, 2),
      child: Row(
        children: <Widget>[
          if (title != null) Text(title!, style: Theme.of(context).textTheme.titleMedium),
          if (count != null) ...<Widget>[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(color: colors.secondaryContainer, borderRadius: BorderRadius.circular(10)),
              child: Text(
                '$count',
                style: TextStyle(color: colors.onSecondaryContainer, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const Spacer(),
          if (onCopy != null)
            IconButton(onPressed: onCopy, icon: const Icon(Icons.copy_all_outlined, size: 20), tooltip: '复制'),
          if (onDelete != null)
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_sweep_outlined, size: 20), tooltip: '清除'),
          const CloseButton(),
        ],
      ),
    );
  }
}
