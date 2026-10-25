import 'package:example/demo/demo_dio.dart';
import 'package:example/demo/theme_mode.dart';
import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/material.dart';

class RequestDemoPage extends StatefulWidget {
  const RequestDemoPage({super.key});

  @override
  State<RequestDemoPage> createState() => _RequestDemoPageState();
}

class _RequestDemoPageState extends State<RequestDemoPage> {
  bool _busy = false;
  String? _busyLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('基础请求'), actions: const <Widget>[ThemeToggleButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const DemoHint(
            'FlDio 的 API 与 Dio 完全一致，区别是请求不会抛异常，'
            '统一返回 FlResponse。下面的结果都可以直接在 JsonParse 中查看。',
          ),
          const SizedBox(height: 20),
          Text('请求方法', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _methodButton('GET', Icons.call_received, () => demoDio.get<Map<String, dynamic>>('/posts/1')),
              _methodButton(
                'POST',
                Icons.add,
                () => demoDio.post<Map<String, dynamic>>(
                  '/posts',
                  data: <String, dynamic>{'title': 'fl_dio', 'body': 'POST demo', 'userId': 1},
                ),
              ),
              _methodButton(
                'PUT',
                Icons.edit_outlined,
                () => demoDio.put<Map<String, dynamic>>(
                  '/posts/1',
                  data: <String, dynamic>{'id': 1, 'title': 'fl_dio', 'body': 'PUT demo', 'userId': 1},
                ),
              ),
              _methodButton(
                'PATCH',
                Icons.build_outlined,
                () => demoDio.patch<Map<String, dynamic>>('/posts/1', data: <String, dynamic>{'title': 'PATCH demo'}),
              ),
              _methodButton('DELETE', Icons.delete_outline, () => demoDio.delete<Map<String, dynamic>>('/posts/1')),
            ],
          ),
          if (_busy) ...<Widget>[
            const SizedBox(height: 18),
            const LinearProgressIndicator(),
            const SizedBox(height: 6),
            Text('正在请求 $_busyLabel ...'),
          ],
          const SizedBox(height: 28),
          Text('错误处理', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.search_off),
                  title: const Text('HTTP 404'),
                  subtitle: const Text('服务端返回错误状态码，type 为 badResponse'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy ? null : () => _run('HTTP 404', demoDio.get<Map<String, dynamic>>('/404')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_off),
                  title: const Text('连接失败'),
                  subtitle: const Text('域名无法访问，type 为 connectionError'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _busy
                      ? null
                      : () => _run('连接失败', demoDio.get<Map<String, dynamic>>('https://invalid.fl-dio.test/')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const DemoHint(
            '请求失败时不会抛异常：通过 response.exception、response.type '
            '和 response.statusCode 判断结果即可。',
          ),
        ],
      ),
    );
  }

  Widget _methodButton(String label, IconData icon, Future<FlResponse<dynamic>> Function() request) {
    return FilledButton.tonalIcon(
      onPressed: _busy ? null : () => _run(label, request()),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Future<void> _run(String label, Future<FlResponse<dynamic>> future) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _busyLabel = label;
    });
    final FlResponse<dynamic> response = await future;
    if (!mounted) return;
    setState(() {
      _busy = false;
      _busyLabel = null;
    });
    await showFlResponse(context, response);
  }
}
