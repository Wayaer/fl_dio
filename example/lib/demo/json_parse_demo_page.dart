import 'package:example/demo/demo_dio.dart';
import 'package:example/demo/theme_mode.dart';
import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/material.dart';

class JsonParseDemoPage extends StatelessWidget {
  const JsonParseDemoPage({super.key});

  static const Map<String, dynamic> _map = <String, dynamic>{
    'name': 'fl_dio',
    'features': <String>['FlDio', 'LoggerInterceptor', 'DebuggerInterceptor', 'JsonParse'],
    'author': <String, dynamic>{'name': 'Wayaer', 'repository': 'https://github.com/Wayaer/fl_dio'},
    'stars': 1024,
    'active': true,
    'deprecated': null,
  };

  static const List<dynamic> _list = <dynamic>[
    <String, dynamic>{'method': 'GET', 'path': '/posts/1', 'status': 200},
    <String, dynamic>{'method': 'POST', 'path': '/posts', 'status': 201},
    <String, dynamic>{'method': 'DELETE', 'path': '/posts/1', 'status': 200},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JsonParse'), actions: const <Widget>[ThemeToggleButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const DemoHint(
            '悬停或点击行会高亮，右侧显示类型标识。'
            '配色取自 ThemeData.colorScheme，切换亮暗或修改 seedColor 会自动变化；'
            '点击箭头展开/折叠，长按值复制，双击 key 复制。',
          ),
          const SizedBox(height: 20),
          Text('Map', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _JsonPanel(child: JsonParse(_map)),
          const SizedBox(height: 20),
          Text('List', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          _JsonPanel(child: JsonParse.list(_list)),
        ],
      ),
    );
  }
}

class _JsonPanel extends StatelessWidget {
  const _JsonPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Padding(padding: const EdgeInsets.all(12), child: child),
    );
  }
}
