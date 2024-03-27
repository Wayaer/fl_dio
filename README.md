# fl_dio

## Extended dio and added three interceptors and the JsonParse component.

### [Example web](https://wayaer.github.io/fl_dio/example/app/web/index.html#/)

```dart
void main() {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 必须设置 DebuggerInterceptorHelper
  /// You must set up DebuggerInterceptorHelper
  DebuggerInterceptorHelper().navigatorKey = navigatorKey;

  /// 设置JsonParse字体颜色
  /// Set the JsonParse font color
  JsonParse.color = JsonParseColor();

  ///  你也可以使用自己的dio，并添加拦截器，拦截器是独立存在的
  ///  You can also use your own dio and add interceptors, which stand alone
  List<Interceptor>list = [

    /// 日志打印
    LoggerInterceptor(),

    /// debug 调试工具
    DebuggerInterceptor(),

    /// cookie 保存和获取
    CookiesInterceptor(),
  ];
  final dio = ExtendedDio()
    ..interceptors.addAll(interceptors);
  
  runApp(MaterialApp(
    navigatorKey: navigatorKey,
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(useMaterial3: true),
    darkTheme: ThemeData.dark(useMaterial3: true),
    home: const Scaffold(body: HomePage()),
  ));
}

```