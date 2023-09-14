import 'dart:convert';

import 'package:fl_dio/fl_dio.dart';
import 'package:fl_dio/src/universal.dart';
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
    return Universal(
        width: double.infinity,
        crossAxisAlignment: CrossAxisAlignment.end,
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 60),
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10))),
        children: [
          const Padding(
              padding: EdgeInsets.only(right: 10), child: CloseButton()),
          Expanded(
              child: ValueListenableBuilder(
                  valueListenable: DebuggerInterceptorHelper()._debugData,
                  builder: (_, Map<int, DebuggerInterceptorDataModel> map, __) {
                    final values = map.values.toList().reversed;
                    return ListView.builder(
                        itemCount: values.length,
                        itemBuilder: (_, int index) =>
                            _Entry(values.elementAt(index), canTap: true));
                  }))
        ]);
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
  ValueNotifier<Offset> iconOffSet =
      ValueNotifier<Offset>(const Offset(10, 10));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iconOffSet.value = Offset(50, MediaQuery.of(context).padding.top + 20);
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;
    return Stack(children: [
      ValueListenableBuilder<Offset>(
          valueListenable: iconOffSet,
          builder: (_, Offset value, __) => Universal(
              left: value.dx,
              top: value.dy,
              enabled: true,
              onTap: show,
              onDoubleTap: widget.hide,
              onPanStart: (DragStartDetails details) =>
                  update(details.globalPosition),
              onPanUpdate: (DragUpdateDetails details) =>
                  update(details.globalPosition),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.bug_report_rounded,
                  size: 23, color: Colors.white)))
    ]);
  }

  Future<void> show() async {
    if (hasWindows) {
      Navigator.of(context).pop();
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
      iconOffSet.value = Offset(dx -= 12, dy -= 26);
    }
  }
}

class _Entry extends StatelessWidget {
  const _Entry(this.model, {this.canTap = false});

  final DebuggerInterceptorDataModel model;

  final bool canTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusCode =
        model.response?.statusCode ?? model.error?.response?.statusCode;
    return Card(
      child: Universal(
          onLongPress: () {
            Clipboard.setData(ClipboardData(text: model.toMap().toString()));
          },
          onTap: () => showDetailData(),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), color: theme.cardColor),
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(model.requestOptions?.method ?? 'unknown',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Universal(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                  decoration: BoxDecoration(
                      color: statusCodeColor(statusCode ?? 0),
                      borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    statusCode?.toString() ?? 'N/A',
                    style: const TextStyle(color: Colors.white),
                  ))
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Universal(
                  visible:
                      model.requestOptions?.baseUrl.contains('https') ?? false,
                  replacement:
                      const Icon(Icons.lock_open, size: 18, color: Colors.grey),
                  child: const Icon(Icons.lock, size: 18, color: Colors.green)),
              Expanded(child: Text(model.requestOptions?.baseUrl ?? 'N/A'))
            ]),
            const SizedBox(height: 10),
            SizedBox(
                width: double.infinity,
                child: Text(model.requestOptions?.path ?? 'unknown',
                    textAlign: TextAlign.start)),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(model.requestTime?.toString() ?? 'unknown')),
              Expanded(
                  child: Text(
                      stringToBytes(model.response?.data?.toString() ?? ''),
                      textAlign: TextAlign.center)),
              Expanded(
                  child: Text(
                      '${diffMillisecond(model.requestTime, model.responseTime)} ms',
                      textAlign: TextAlign.end)),
            ]),
          ]),
    );
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

  void showDetailData() {
    if (!canTap) return;
    final navigatorKey = DebuggerInterceptorHelper().navigatorKey;
    if (navigatorKey.currentContext != null) {
      showCupertinoModalPopup(
          context: navigatorKey.currentContext!,
          builder: (_) => const _DebuggerList());
    }
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

class _DebuggerDetail extends StatefulWidget {
  const _DebuggerDetail(this.model);

  final DebuggerInterceptorDataModel model;

  @override
  State<_DebuggerDetail> createState() => _DebuggerDetailState();
}

class _DebuggerDetailState extends State<_DebuggerDetail>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  List<String> tabs = ['request', 'response', 'error'];

  @override
  void initState() {
    super.initState();
    controller = TabController(length: tabs.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    return Universal(
        width: double.infinity,
        crossAxisAlignment: CrossAxisAlignment.end,
        margin: EdgeInsets.only(top: mediaQuery.padding.top + 80),
        decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(10))),
        children: [
          const Padding(
              padding: EdgeInsets.only(right: 10), child: CloseButton()),
          _Entry(widget.model),
          Expanded(
              child: Column(children: [
            TabBar(
                labelColor: theme.indicatorColor,
                labelStyle: TextStyle(
                    color: theme.indicatorColor, fontWeight: FontWeight.bold),
                indicatorSize: TabBarIndicatorSize.label,
                controller: controller,
                tabs: tabs.map((item) => Tab(child: Text(item))).toList()),
            Expanded(
                child: TabBarView(
                    controller: controller,
                    children: tabs.map((item) {
                      Widget entry = const SizedBox();
                      if (item == tabs.first) {
                        entry = JsonParse(widget.model.requestOptionsToMap());
                      } else if (item == tabs[1]) {
                        entry = JsonParse(widget.model.responseToMap());
                      } else if (item == tabs.last) {
                        entry = JsonParse(widget.model.errorToMap());
                      }
                      return Universal(
                          isScroll: true,
                          safeBottom: true,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: entry);
                    }).toList()))
          ])),
        ]);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}
