import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/material.dart';

GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  DebuggerInterceptorHelper().navigatorKey = navigatorKey;
  ExtendedDio().initialize(interceptors: [
    DebuggerInterceptor(),
    LoggerInterceptor(),
    CookiesInterceptor(),
  ]);
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    home: const Scaffold(body: HomePage()),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          ]),
    );
  }

  void get() async {
    await ExtendedDio().get(
        'https://lf3-beecdn.bytetos.com/obj/ies-fe-bee/bee_prod/biz_216/bee_prod_216_bee_publish_6676.json');
  }

  void post() async {
    showSnackBar('未添加');
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

  void download() async {}

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
