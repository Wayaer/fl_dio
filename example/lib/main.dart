import 'package:example/demo/demo_dio.dart';
import 'package:example/demo/interceptor_demo_page.dart';
import 'package:example/demo/json_parse_demo_page.dart';
import 'package:example/demo/request_demo_page.dart';
import 'package:example/demo/theme_mode.dart';
import 'package:example/demo/transfer_demo_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// 项目主页、作者与示例信息。
const String _githubUrl = 'https://github.com/Wayaer/fl_dio';
const String _pubDevUrl = 'https://pub.dev/packages/fl_dio';
const String _author = 'Wayaer';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDemoDio();
  runApp(const FlDioDemoApp());
}

class FlDioDemoApp extends StatelessWidget {
  const FlDioDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seed = Colors.indigo;
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (BuildContext context, ThemeMode mode, _) => MaterialApp(
        title: 'FlDio',
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(colorSchemeSeed: seed),
        darkTheme: ThemeData(colorSchemeSeed: seed, brightness: Brightness.dark),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('fl_dio'), actions: const <Widget>[ThemeToggleButton()]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: <Widget>[
          const _IntroCard(),
          const SizedBox(height: 16),
          _DemoTile(
            icon: Icons.swap_horiz,
            title: '基础请求',
            subtitle: 'GET / POST / PUT / PATCH / DELETE，统一返回 FlResponse',
            pageBuilder: (_) => const RequestDemoPage(),
          ),
          _DemoTile(
            icon: Icons.arrow_downward,
            title: '下载与上传',
            subtitle: '进度回调与取消请求，自动适配 Web 和原生端',
            pageBuilder: (_) => const TransferDemoPage(),
          ),
          _DemoTile(
            icon: Icons.filter_alt_outlined,
            title: '拦截器',
            subtitle: 'Logger / Debugger / Cookies / ExtraParams',
            pageBuilder: (_) => const InterceptorDemoPage(),
          ),
          _DemoTile(
            icon: Icons.data_object,
            title: 'JsonParse',
            subtitle: '可折叠的 JSON 查看器，支持复制与自定义颜色',
            pageBuilder: (_) => const JsonParseDemoPage(),
          ),
          const SizedBox(height: 8),
          const _AboutCard(),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('FlDio', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
              '与 Dio API 一致，不需要 try/catch：所有请求统一返回 FlResponse，'
              '并内置四个拦截器、JsonParse、通用适配器和常用扩展方法。',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const <Widget>[
                Chip(label: Text('No try/catch')),
                Chip(label: Text('4 Interceptors')),
                Chip(label: Text('JsonParse')),
                Chip(label: Text('Web / Native')),
              ],
            ),
            const SizedBox(height: 12),
            Text('作者：$_author · $_githubUrl', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile({required this.icon, required this.title, required this.subtitle, required this.pageBuilder});

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder pageBuilder;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: pageBuilder)),
      ),
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('关于 fl_dio', style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text('作者：$_author', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(
              '扩展 dio 的 Flutter 库：请求统一返回 FlResponse，内置四个拦截器、'
              'JsonParse、通用适配器和常用扩展方法。',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _LinkRow(label: 'GitHub', url: _githubUrl),
            const SizedBox(height: 8),
            _LinkRow(label: 'pub.dev', url: _pubDevUrl),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({required this.label, required this.url});

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = theme.colorScheme.primary;
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _open,
        onLongPress: _copy,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Icon(Icons.link, size: 18, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: theme.textTheme.labelSmall),
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: color, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _open() async {
    try {
      final bool opened = await launchUrl(Uri.parse(url));
      if (!opened) showMessage('无法打开：$url');
    } catch (_) {
      showMessage('无法打开：$url');
    }
  }

  void _copy() {
    Clipboard.setData(ClipboardData(text: url));
    showMessage('已复制：$url');
  }
}
