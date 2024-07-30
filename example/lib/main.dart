import 'dart:convert';

import 'package:device_preview_minus/device_preview_minus.dart';
import 'package:fl_dio/fl_dio.dart';
import 'package:fl_extended/fl_extended.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final interceptors = [
  /// 数据扩展
  ExtraParamsInterceptor(
      onExtraHeader: (Uri uri, Map<String, dynamic> headers) {
    dioLog('onExtraHeader: $headers');
    return null;
  }, onExtraData: (Uri uri, dynamic data) {
    dioLog('onExtraData: $data');
    return null;
  }, onExtraParams: (Uri uri, Map<String, dynamic> params) {
    dioLog('onExtraParams: $params');
    return null;
  }, onExtraPath: (Uri uri) {
    dioLog('onExtraPath: $uri');
    return null;
  }),

  /// 日志打印
  LoggerInterceptor(),

  /// debug 调试工具
  DebuggerInterceptor(),

  /// cookie 保存和获取
  CookiesInterceptor(),
];

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// 必须设置 DebuggerInterceptorHelper
  DebuggerInterceptorHelper().navigatorKey = navigatorKey;

  /// 设置JsonParse字体颜色
  JsonParse.color = JsonParseColor();

  /// 初始化Toast工具
  FlExtended().navigatorKey = navigatorKey;

  /// toast 提示
  JsonParse.toastBuilder = (String content) {
    showToast('已复制：$content');
  };

  runApp(DevicePreview(
      enabled: kIsWeb,
      defaultDevice: Devices.ios.iPhone13Mini,
      builder: (context) => MaterialApp(
          navigatorKey: navigatorKey,
          locale: DevicePreview.locale(context),
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          debugShowCheckedModeBanner: false,
          builder: (BuildContext context, Widget? child) {
            return DevicePreview.appBuilder(context, child);
          },
          home: const Scaffold(body: HomePage()))));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dio = ExtendedDio()..interceptors.addAll(interceptors);
  final url =
      'https://lf3-beecdn.bytetos.com/obj/ies-fe-bee/bee_prod/biz_216/bee_prod_216_bee_publish_6676.json';

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Wrap(
          runSpacing: 12,
          spacing: 12,
          alignment: WrapAlignment.center,
          children: [
            ElevatedText('show', onPressed: DebuggerInterceptorHelper().show),
            ElevatedText('showDebugger',
                onPressed: DebuggerInterceptorHelper().showDebugger),
            ElevatedText('hide', onPressed: DebuggerInterceptorHelper().hide),
            ElevatedText('get', onPressed: get),
            ElevatedText('post', onPressed: post),
            ElevatedText('put', onPressed: put),
            ElevatedText('delete', onPressed: delete),
            ElevatedText('patch', onPressed: patch),
            ElevatedText('download', onPressed: download),
            ElevatedText('upload', onPressed: upload),
            ElevatedText('JsonParse', onPressed: () {
              showCupertinoModalPopup(
                  context: context, builder: (_) => const JsonParsePage());
            }),
          ]),
    );
  }

  void get() async {
    await dio.get(url);
  }

  void post() async {
    await dio.post(url);
  }

  void put() async {
    showSnackBar('未添加');
  }

  void delete() async {
    showSnackBar('未添加');
  }

  void patch() async {
    showSnackBar('未添加');
  }

  void download() async {
    final dir = await getApplicationCacheDirectory();
    ExtendedDio().download(
        'https://downv6.qq.com/qqweb/QQ_1/android_apk/Android_8.9.28.10155_537147618_64.apk',
        '${dir.path}/file.apk', onReceiveProgress: (int count, int total) {
      dioLog((count / total).toDouble());
    });
  }

  void upload() async {
    showSnackBar('未添加');
  }

  void showSnackBar(String text) {
    scaffoldMessengerKey.currentState
        ?.showSnackBar(SnackBar(content: Text(text)));
  }
}

class ElevatedText extends ElevatedButton {
  ElevatedText(String text, {required super.onPressed, super.key})
      : super(child: Text(text));
}

class JsonParsePage extends StatelessWidget {
  const JsonParsePage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<dynamic, dynamic> map =
        jsonDecode('{"name":"BeJson","url":"http://www.bejson.com",'
                '"page":88,"num":88.88,"isNonProfit":true,"address":'
                '{"street":"科技园路.","city":"江苏苏州","country":"中国"},'
                '"links":[{"name":"Google","url":"http://www.google.com"},'
                '{"name":"Baidu","url":"http://www.baidu.com"},'
                '{"name":"SoSo","url":"http://www.SoSo.com"}]}')
            as Map<dynamic, dynamic>;
    final List<dynamic> list = jsonDecode(
            '[{"name":"Google","url":"http://www.google.com"},{"name":"Baidu",'
            '"url":"http://www.baidu.com"},{"name":"SoSo","url":"http://www.SoSo.com"}]')
        as List<dynamic>;
    return Scaffold(
        appBar: AppBar(title: const Text('JsonParse')),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            const Text('JsonParse'),
            Card(child: JsonParse(map)),
            const Text('JsonParse.list'),
            Card(child: JsonParse.list(list))
          ]),
        )));
  }
}
