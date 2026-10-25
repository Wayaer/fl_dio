import 'package:example/demo/demo_dio.dart';
import 'package:example/demo/theme_mode.dart';
import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InterceptorDemoPage extends StatefulWidget {
  const InterceptorDemoPage({super.key});

  @override
  State<InterceptorDemoPage> createState() => _InterceptorDemoPageState();
}

class _InterceptorDemoPageState extends State<InterceptorDemoPage> {
  final ExtraParamsInterceptor _extra = ExtraParamsInterceptor();
  late final CookiesInterceptor _cookies = CookiesInterceptor(
    setCookies: (RequestOptions options) =>
        _cookieEnabled ? <String, dynamic>{'Cookie': 'token=fl_dio; source=demo'} : const <String, dynamic>{},
    getCookies: _onCookies,
  );
  late final FlDio _dio;

  bool _extraEnabled = false;
  bool _cookieEnabled = false;
  bool _busy = false;
  List<String> _receivedCookies = <String>[];

  bool get _cookieSupported => !kIsWeb;

  @override
  void initState() {
    super.initState();
    _dio = FlDio(
      BaseOptions(
        baseUrl: 'https://httpbin.org',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ),
    )..interceptors.addAll(<Interceptor>[_extra, LoggerInterceptor(), DebuggerInterceptor(enabled: true), _cookies]);
    _dio.httpClientAdapter = UniversalHttpClientAdapter().create();
  }

  @override
  Widget build(BuildContext context) {
    final DebuggerInterceptorHelper debugger = DebuggerInterceptorHelper();
    return Scaffold(
      appBar: AppBar(title: const Text('拦截器'), actions: const <Widget>[ThemeToggleButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const DemoHint(
            '四个拦截器可以独立使用，也可以加到自己已有的 Dio 实例上。'
            '本页使用独立的 FlDio 实例，请求 httpbin 后会原样返回 headers 和参数。',
          ),
          const SizedBox(height: 20),
          _card(
            title: 'ExtraParamsInterceptor',
            subtitle: '请求前统一追加 header、query、path 或 data',
            child: Column(
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('启用扩展参数'),
                  subtitle: const Text('追加 X-Fl-Dio header 和 source 查询参数'),
                  value: _extraEnabled,
                  onChanged: _toggleExtra,
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            _dio.get<Map<String, dynamic>>('/get', queryParameters: <String, dynamic>{'foo': 'bar'}),
                          ),
                    child: const Text('请求 /get'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'CookiesInterceptor',
            subtitle: '发送请求 Cookie，并读取响应 Set-Cookie',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('启用 Cookie 注入'),
                  subtitle: const Text('通过 setCookies 返回 Cookie 请求头'),
                  value: _cookieEnabled,
                  onChanged: _cookieSupported ? _toggleCookie : null,
                ),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: !_cookieSupported || _busy
                          ? null
                          : () => _run(_dio.get<Map<String, dynamic>>('/cookies')),
                      child: const Text('请求 /cookies'),
                    ),
                    OutlinedButton(
                      onPressed: !_cookieSupported || _busy
                          ? null
                          : () => _run(
                              _dio.get<Map<String, dynamic>>(
                                '/response-headers',
                                queryParameters: <String, dynamic>{'Set-Cookie': 'token=from_server'},
                              ),
                            ),
                      child: const Text('读取 Set-Cookie'),
                    ),
                  ],
                ),
                if (_receivedCookies.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _receivedCookies.map((String value) => Chip(label: Text(value))).toList(),
                  ),
                ],
                if (!_cookieSupported) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    '浏览器禁止脚本设置/读取 Cookie 请求头与 Set-Cookie，'
                    '该拦截器请在 iOS、Android 或桌面端体验。',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'DebuggerInterceptor',
            subtitle: '请求完成后自动显示悬浮入口，点按查看请求、响应和错误',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: <Widget>[
                FilledButton.tonal(onPressed: debugger.show, child: const Text('显示悬浮按钮')),
                OutlinedButton(onPressed: debugger.showDebugger, child: const Text('打开调试面板')),
                OutlinedButton(onPressed: debugger.hide, child: const Text('隐藏')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: 'LoggerInterceptor',
            subtitle: '请求、响应和错误日志输出到控制台',
            child: Text(
              '支持 filtered、hideRequest、hideResponse、printResponseHeader、'
              'printErrorResponse、requestDataToJson、responseToJson 等参数。'
              '运行示例后在 IDE 控制台查看格式化日志。',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required String title, required String subtitle, required Widget child}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  void _toggleExtra(bool value) {
    setState(() => _extraEnabled = value);
    _extra.onExtraHeader = value
        ? (Uri uri, Map<String, dynamic> headers) => <String, dynamic>{...headers, 'X-Fl-Dio': 'demo'}
        : null;
    _extra.onExtraParams = value
        ? (Uri uri, Map<String, dynamic> params) => <String, dynamic>{...params, 'source': 'fl_dio'}
        : null;
  }

  void _toggleCookie(bool value) {
    setState(() => _cookieEnabled = value);
  }

  void _onCookies(Response<dynamic> response) {
    final List<String> cookies = response.headers.map['set-cookie'] ?? <String>[];
    if (!mounted || cookies.isEmpty) return;
    setState(() => _receivedCookies = cookies);
  }

  Future<void> _run(Future<FlResponse<dynamic>> future) async {
    if (_busy) return;
    setState(() => _busy = true);
    final FlResponse<dynamic> response = await future;
    if (!mounted) return;
    setState(() => _busy = false);
    await showFlResponse(context, response);
  }
}
