import 'dart:convert';

import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    DebuggerInterceptorHelper().show();
    super.onError(err, handler);
  }
}

class DebuggerInterceptorHelper {
  factory DebuggerInterceptorHelper() =>
      _singleton ??= DebuggerInterceptorHelper._();

  DebuggerInterceptorHelper._();

  static DebuggerInterceptorHelper? _singleton;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  OverlayEntry? _overlayEntry;

  final ValueNotifier<Map<int, DebuggerInterceptorDataModel>> _debugData =
      ValueNotifier({});

  void show() {
    _overlayEntry ??=
        _showOverlay(_DebuggerIcon(show: showDebugger, hide: hide));
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> showDebugger() async {
    if (navigatorKey.currentContext != null) {
      await showCupertinoModalPopup(
          context: navigatorKey.currentContext!,
          builder: (_) => const _DebuggerList());
    }
  }

  /// 自定义Overlay
  OverlayEntry? _showOverlay(Widget widget) {
    final OverlayState? overlay = navigatorKey.currentState!.overlay;
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
    final theme = Theme.of(context);
    return Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 30),
        child: Material(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
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
                            itemBuilder: (_, int index) =>
                                itemBuilder(map, index))))
              ]),
            )));
  }

  Widget itemBuilder(Map<int, DebuggerInterceptorDataModel> map, int index) {
    final model = map.values.elementAt(index);
    final key = map.keys.elementAt(index);
    return _Entry(model, onTap: () {
      final navigatorKey = DebuggerInterceptorHelper().navigatorKey;
      if (navigatorKey.currentContext != null) {
        showCupertinoModalPopup(
            barrierColor: Colors.transparent,
            context: navigatorKey.currentContext!,
            builder: (_) => _DebuggerDetail(key, model));
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
  Offset offSet = const Offset(10, 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      offSet = Offset(30, MediaQuery.of(context).padding.top + 20);
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

class _Entry extends StatelessWidget {
  const _Entry(this.model, {this.onTap});

  final DebuggerInterceptorDataModel model;

  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final statusCode =
        model.response?.statusCode ?? model.error?.response?.statusCode;
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
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
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                                color: statusCodeColor(statusCode ?? 0),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(statusCode?.toString() ?? 'N/A',
                                style: const TextStyle(color: Colors.white)))
                      ]),
                  const SizedBox(height: 4),
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
                        child: Text(model.requestOptions?.baseUrl ?? 'N/A'))
                  ]),
                  const SizedBox(height: 4),
                  SizedBox(
                      width: double.infinity,
                      child: Text(model.requestOptions?.path ?? 'unknown',
                          textAlign: TextAlign.left)),
                  const SizedBox(height: 4),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text(requestTime(model.requestTime))),
                        Expanded(
                            flex: 2,
                            child: Text(
                                stringToBytes(
                                    model.response?.data?.toString() ?? ''),
                                textAlign: TextAlign.center)),
                        Expanded(
                            child: Text(
                                '${diffMillisecond(model.requestTime, model.responseTime)} ms',
                                textAlign: TextAlign.end)),
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
    if (statusCode >= 100 && statusCode < 200) {
      return Colors.blue;
    } else if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.yellow;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.orange;
    } else if (statusCode >= 500) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }
}

class _DebuggerDetail extends StatelessWidget {
  const _DebuggerDetail(this.iKey, this.model);

  final DebuggerInterceptorDataModel model;
  final int iKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final tabs = ['request', 'response', 'error'];
    return DefaultTabController(
        length: tabs.length,
        child: Padding(
          padding: EdgeInsets.only(
              top: mediaQuery.padding.top + 30, left: 8, right: 8, bottom: 8),
          child: Material(
              color: theme.scaffoldBackgroundColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(10)),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                _Toolbar(onDelete: () {
                  Navigator.of(context).maybePop();
                  final map =
                      Map.of(DebuggerInterceptorHelper()._debugData.value);
                  map.remove(iKey);
                  DebuggerInterceptorHelper()._debugData.value = map;
                }),
                _Entry(model),
                Expanded(
                    child: Column(children: [
                  SizedBox(
                      height: 38,
                      child: TabBar(
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: tabs.map((item) => Tab(text: item)).toList())),
                  Expanded(
                      child: Padding(
                    padding: EdgeInsets.only(
                        bottom: mediaQuery.padding.bottom, top: 10),
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
                    }).toList()),
                  ))
                ])),
              ])),
        ));
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
