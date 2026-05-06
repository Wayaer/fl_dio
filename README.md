# fl_dio

## Extended dio and added three interceptors and the JsonParse component.

### [Example web](https://wayaer.github.io/fl_dio/example/app/web/index.html#/)

### 使用方法和 `Dio` 一致，只需替换 `Dio` 为 `ExtendedDio` 就可以不用写 `try catch` ,统一返回 `ExtendedResponse`

```dart
void main() {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// 必须设置 DebuggerInterceptorHelper
  /// You must set up DebuggerInterceptorHelper
  DebuggerInterceptorHelper().navigatorKey = navigatorKey;

  /// 设置JsonParse字体颜色
  /// Set the JsonParse font color
  JsonParse.color = JsonParseColor();

  /// toast 提示
  /// toast Tips
  JsonParse.toastBuilder = (String content) {
    showToast('已复制：$content');
  };

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
    home: const Scaffold(body: HomePage()),
  ));
}

```