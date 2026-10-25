import 'package:flutter/material.dart';

/// 示例应用的明暗模式，默认跟随系统。
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

/// 在白天和黑夜之间切换。
void toggleThemeMode(BuildContext context) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
}

/// AppBar 上的明暗切换按钮。
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: isDark ? '切换到白天模式' : '切换到黑夜模式',
      onPressed: () => toggleThemeMode(context),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );
  }
}
