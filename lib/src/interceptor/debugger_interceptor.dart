import 'dart:convert';

import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _ValueNotifiers<T> extends ValueNotifier<T> {
  _ValueNotifiers(super.value);

  void notify() {
    notifyListeners();
  }
}

class DebuggerInterceptorDataModel {
  DebuggerInterceptorDataModel(
      {this.requestOptions, this.response, this.error});

  RequestOptions? requestOptions;

  Response<dynamic>? response;

  DioException? error;

  DateTime? requestTime;

  DateTime? responseTime;

  DateTime? errorTime;

  Map<String, dynamic> toMap() => {
        'requestOptions': requestOptionsToMap(),
        'response': responseToMap(),
        'error': errorToMap(),
      };

  Map<String, dynamic> requestOptionsToMap() => {
        ...requestOptions?.toMap() ?? {},
        'requestTime': requestTime?.toString()
      };

  Map<String, dynamic> responseToMap() =>
      {...response?.toMap() ?? {}, 'responseTime': responseTime?.toString()};

  Map<String, dynamic> errorToMap() =>
      {...error?.toMap() ?? {}, 'errorTime': errorTime?.toString()};
}

class DebuggerInterceptor extends InterceptorsWrapper {
  DebuggerInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final dataModel = DebuggerInterceptorDataModel();
    dataModel.requestTime = DateTime.now();
    dataModel.requestOptions = options;
    DebuggerInterceptorHelper()._debugData.value[options.hashCode] = dataModel;
    DebuggerInterceptorHelper()._debugData.notify();
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    DebuggerInterceptorHelper()
        ._debugData
        .value[response.requestOptions.hashCode]
        ?.response = response;
    DebuggerInterceptorHelper()
        ._debugData
        .value[response.requestOptions.hashCode]
        ?.responseTime = DateTime.now();
    DebuggerInterceptorHelper()._debugData.notify();
    DebuggerInterceptorHelper().show();
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    DebuggerInterceptorHelper()
        ._debugData
        .value[err.requestOptions.hashCode]
        ?.error = err;
    DebuggerInterceptorHelper()
        ._debugData
        .value[err.requestOptions.hashCode]
        ?.errorTime = DateTime.now();
    DebuggerInterceptorHelper()._debugData.notify();
    DebuggerInterceptorHelper().show();
    super.onError(err, handler);
  }
}

class DebuggerInterceptorHelper {
  factory DebuggerInterceptorHelper() =>
      _singleton ??= DebuggerInterceptorHelper._();

  DebuggerInterceptorHelper._();

  static DebuggerInterceptorHelper? _singleton;

  GlobalKey<NavigatorState>? navigatorKey;

  OverlayEntry? _overlayEntry;

  final _ValueNotifiers<Map<int, DebuggerInterceptorDataModel>> _debugData =
      _ValueNotifiers({});

  void show() {
    _overlayEntry ??=
        _showOverlay(_DebuggerIcon(show: showDebugger, hide: hide));
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> showDebugger() async {
    if (navigatorKey != null && navigatorKey!.currentContext != null) {
      await showModalBottomSheet(
          context: navigatorKey!.currentContext!,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const _DebuggerList());
    }
  }

  /// 自定义Overlay
  OverlayEntry? _showOverlay(Widget widget) {
    if (navigatorKey == null) return null;
    final OverlayState? overlay = navigatorKey!.currentState!.overlay;
    if (overlay == null) return null;
    final entry = OverlayEntry(builder: (_) => widget);
    overlay.insert(entry);
    return entry;
  }
}

class _DebuggerList extends StatelessWidget {
  const _DebuggerList();

  @override
  Widget build(BuildContext context) {
    return Material(
        type: MaterialType.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          _Toolbar(onDelete: () {
            DebuggerInterceptorHelper()._debugData.value = {};
          }),
          Expanded(
              child: ValueListenableBuilder<
                      Map<int, DebuggerInterceptorDataModel>>(
                  valueListenable: DebuggerInterceptorHelper()._debugData,
                  builder: (_, map, __) => ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: map.length,
                      itemBuilder: (_, int index) => itemBuilder(map, index))))
        ]));
  }

  Widget itemBuilder(Map<int, DebuggerInterceptorDataModel> map, int index) {
    final value = map.values.toList().reversed.elementAt(index);
    final key = map.keys.toList().reversed.elementAt(index);
    return _HttpCard(value, onTap: () {
      final navigatorKey = DebuggerInterceptorHelper().navigatorKey;
      if (navigatorKey != null && navigatorKey.currentContext != null) {
        showModalBottomSheet(
            isScrollControlled: true,
            useSafeArea: true,
            context: navigatorKey.currentContext!,
            builder: (_) => _DebuggerDetail(key, value));
      }
    });
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
  Offset offSet = const Offset(60, 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      offSet = Offset(60, MediaQuery.of(context).padding.top + 8);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Stack(children: [
      Positioned(
          left: offSet.dx,
          top: offSet.dy,
          child: GestureDetector(
            onTap: show,
            onDoubleTap: widget.hide,
            onPanStart: (DragStartDetails details) =>
                update(details.globalPosition),
            onPanUpdate: (DragUpdateDetails details) =>
                update(details.globalPosition),
            child: Container(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.bug_report_rounded,
                    size: 23, color: Colors.white)),
          ))
    ]);
  }

  Future<void> show() async {
    if (hasWindows) {
      Navigator.of(context).maybePop();
    } else {
      hasWindows = true;
      await widget.show();
      hasWindows = false;
    }
  }

  void update(Offset offset) {
    final mediaQuery = MediaQuery.of(context);
    if (offset.dx > 1 &&
        offset.dx < mediaQuery.size.height - 24 &&
        offset.dy > mediaQuery.padding.top &&
        offset.dy < mediaQuery.size.height - mediaQuery.padding.bottom - 24) {
      double dy = offset.dy;
      double dx = offset.dx;
      offSet = Offset(dx -= 12, dy -= 26);
      setState(() {});
    }
  }
}

class _HttpCard extends StatelessWidget {
  const _HttpCard(this.model, {this.onTap});

  final DebuggerInterceptorDataModel model;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusCode =
        model.response?.statusCode ?? model.error?.response?.statusCode;
    final textTheme = Theme.of(context).textTheme;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
                onLongPress: () {
                  Clipboard.setData(
                      ClipboardData(text: model.toMap().toString()));
                },
                onTap: onTap,
                child: Column(children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(model.requestOptions?.method ?? 'unknown',
                            style: (textTheme.bodyLarge ?? const TextStyle())
                                .copyWith(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                                color: statusCodeColor(statusCode ?? 0),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(statusCode?.toString() ?? 'N/A',
                                style:
                                    (textTheme.bodyMedium ?? const TextStyle())
                                        .copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)))
                      ]),
                  const SizedBox(height: 2),
                  Row(children: [
                    Visibility(
                        visible:
                            model.requestOptions?.baseUrl.contains('https') ??
                                false,
                        replacement: const Icon(Icons.lock,
                            size: 18, color: Colors.green),
                        child: const Icon(Icons.lock_open,
                            size: 18, color: Colors.green)),
                    Expanded(
                        child: Text(model.requestOptions?.baseUrl ?? 'N/A',
                            style: textTheme.bodyMedium))
                  ]),
                  const SizedBox(height: 4),
                  SizedBox(
                      width: double.infinity,
                      child: Text(model.requestOptions?.path ?? 'unknown',
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.left)),
                  const SizedBox(height: 4),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 5,
                            child: Text(requestTime(model.requestTime),
                                style: textTheme.bodySmall)),
                        Expanded(
                            flex: 2,
                            child: Text(
                                stringToBytes(
                                    model.response?.data?.toString() ?? ''),
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall)),
                        Expanded(
                            flex: 2,
                            child: Text(
                                '${diffMillisecond(model.requestTime, model.responseTime)} ms',
                                textAlign: TextAlign.end,
                                style: textTheme.bodySmall)),
                      ]),
                ]))));
  }

  String requestTime(DateTime? requestTime) {
    if (requestTime == null) return 'unknown';
    var str = requestTime.toString();
    if (str.contains('.')) {
      str = str.substring(0, str.indexOf('.'));
    }
    return str;
  }

  String stringToBytes(String data) {
    final bytes = utf8.encode(data);
    final size = Uint8List.fromList(bytes);
    return size.lengthInBytes.toStorageUnit();
  }

  String diffMillisecond(DateTime? requestTime, DateTime? responseTime) {
    if (requestTime == null || responseTime == null) return '';
    return responseTime.difference(requestTime).inMilliseconds.toString();
  }

  Color statusCodeColor(int statusCode) {
    if (statusCode == 200) return Colors.green;
    return Colors.red;
  }
}

class _DebuggerDetail extends StatelessWidget {
  const _DebuggerDetail(this.iKey, this.model);

  final DebuggerInterceptorDataModel model;
  final int iKey;

  @override
  Widget build(BuildContext context) {
    final tabs = ['request', 'response', 'error'];
    return DefaultTabController(
        length: tabs.length,
        child: Material(
            type: MaterialType.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              _Toolbar(onDelete: () {
                Navigator.of(context).maybePop();
                final map =
                    Map.of(DebuggerInterceptorHelper()._debugData.value);
                map.remove(iKey);
                DebuggerInterceptorHelper()._debugData.value = map;
              }),
              _HttpCard(model),
              Expanded(
                  child: Column(children: [
                SizedBox(
                    height: 38,
                    child: TabBar(
                        indicatorSize: TabBarIndicatorSize.label,
                        tabs: tabs.map((item) => Tab(text: item)).toList())),
                Expanded(
                    child: TabBarView(
                        children: tabs.map((item) {
                  Widget entry = const SizedBox();
                  if (item == tabs.first) {
                    entry = JsonParse(model.requestOptionsToMap());
                  } else if (item == tabs[1]) {
                    entry = JsonParse(model.responseToMap());
                  } else if (item == tabs.last) {
                    entry = JsonParse(model.errorToMap());
                  }
                  return Card(child: entry);
                }).toList()))
              ])),
            ])));
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({this.onDelete});

  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      IconButton(onPressed: onDelete, icon: const Icon(Icons.delete, size: 19)),
      const CloseButton(),
    ]);
  }
}
