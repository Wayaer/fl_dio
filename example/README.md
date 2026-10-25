# FlDio example

由 [Wayaer](https://github.com/Wayaer) 维护的 [`fl_dio`](https://github.com/Wayaer/fl_dio) 示例应用。

- GitHub: <https://github.com/Wayaer/fl_dio>
- pub.dev: <https://pub.dev/packages/fl_dio>
- 在线体验: <https://wayaer.github.io/fl_dio/example/app/web/index.html#/>
- 运行环境: Flutter 3.47.0+ / Dart 3.13.0+

每个页面覆盖库的不同部分：

- **基础请求** — GET / POST / PUT / PATCH / DELETE，统一返回 `FlResponse`，结果用 `JsonParse` 展示
- **错误处理** — 404 与连接失败，不写 `try/catch`
- **下载与上传** — 进度回调、`CancelToken`；Web 端下载读取字节流，原生端写入临时目录
- **拦截器** — `LoggerInterceptor`、`DebuggerInterceptor`、`CookiesInterceptor`、`ExtraParamsInterceptor`
- **JsonParse** — Map / List 折叠、行高亮、类型标识、主题配色、长按复制
- **明暗主题** — AppBar 右上角切换白天/黑夜，JsonParse 会跟随 `Theme.colorScheme` 自动换色

## Run

```bash
flutter pub get
flutter run -d chrome   # web
flutter run -d ios      # iOS
```

## Notes

- Demo endpoints: `jsonplaceholder.typicode.com` and `httpbin.org`.
- iOS 在 `ios/Runner/Info.plist` 中开启了 ATS 例外（`NSAllowsArbitraryLoads`、
  `NSAllowsLocalNetworking`）和本地网络权限说明，方便演示 HTTP 与局域网请求；
  正式项目请改成按域名配置。
- Browsers do not allow scripts to set the `Cookie` request header or read
  `Set-Cookie`, so the cookie demo is limited to native platforms.
- `DebuggerInterceptor` needs a `navigatorKey` (already configured in
  `lib/demo/demo_dio.dart`).
