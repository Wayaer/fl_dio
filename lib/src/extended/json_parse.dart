import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonParseColor {
  const JsonParseColor({
    this.typeMap = const Color(0xFF64748B),
    this.typeList = const Color(0xFF64748B),
    this.typeNull = const Color(0xFF94A3B8),
    this.typeNum = const Color(0xFFC2410C),
    this.typeString = const Color(0xFF047857),
    this.typeBool = const Color(0xFF4F46E5),
    this.typeObject = const Color(0xFF64748B),
    this.arrow,
    this.key = const Color(0xFF1E293B),
    this.keyContentNull = const Color(0xFF94A3B8),
    this.highlight,
  });

  /// 从 Flutter 主题生成配色：字符串使用 primary，数字使用 tertiary，
  /// 布尔使用 secondary，key 使用 onSurface，结构类型使用 onSurfaceVariant / outline。
  /// 修改 ColorScheme 的 seedColor 或切换亮暗主题后会自动变化。
  factory JsonParseColor.from(ColorScheme scheme) {
    final bool dark = scheme.brightness == Brightness.dark;
    return JsonParseColor(
      typeMap: scheme.onSurfaceVariant,
      typeList: scheme.onSurfaceVariant,
      typeNull: scheme.outline,
      typeNum: scheme.tertiary,
      typeString: scheme.primary,
      typeBool: scheme.secondary,
      typeObject: scheme.onSurfaceVariant,
      arrow: scheme.outline,
      key: scheme.onSurface,
      keyContentNull: scheme.outline,
      highlight: scheme.primary.withValues(alpha: dark ? 0.16 : 0.08),
    );
  }

  final Color typeMap;
  final Color typeList;
  final Color typeNull;
  final Color typeNum;
  final Color typeString;
  final Color typeBool;
  final Color typeObject;
  final Color? arrow;
  final Color key;
  final Color keyContentNull;

  /// 行高亮颜色，为空时使用 primary 的低透明度叠加
  final Color? highlight;

  JsonParseColor copyWith({
    Color? typeMap,
    Color? typeList,
    Color? typeNull,
    Color? typeNum,
    Color? typeString,
    Color? typeBool,
    Color? typeObject,
    Color? arrow,
    Color? key,
    Color? keyContentNull,
    Color? highlight,
  }) {
    return JsonParseColor(
      typeMap: typeMap ?? this.typeMap,
      typeList: typeList ?? this.typeList,
      typeNull: typeNull ?? this.typeNull,
      typeNum: typeNum ?? this.typeNum,
      typeString: typeString ?? this.typeString,
      typeBool: typeBool ?? this.typeBool,
      typeObject: typeObject ?? this.typeObject,
      arrow: arrow ?? this.arrow,
      key: key ?? this.key,
      keyContentNull: keyContentNull ?? this.keyContentNull,
      highlight: highlight ?? this.highlight,
    );
  }
}

typedef JsonParseTextBuilder = Widget Function(Color color, String content);
typedef JsonParseToastBuilder = void Function(String content);

class JsonParse extends StatefulWidget {
  JsonParse(this.json, {super.key, this.depth = 0}) : list = <dynamic>[], isList = false;

  JsonParse.list(this.list, {super.key, this.depth = 0}) : json = list.asMap(), isList = true;

  /// 最大展开层级，避免循环引用或超深结构导致栈溢出
  static int maxDepth = 20;

  static JsonParseColor? _customColor;

  /// 当前自定义配色；未设置时返回固定的兜底配色，实际渲染以 [resolveColor] 为准
  static JsonParseColor get color => _customColor ?? JsonParseColor();

  /// 设置后固定使用该配色，不再跟随亮暗主题
  static set color(JsonParseColor value) => _customColor = value;

  /// 未设置 [color] 时，可基于当前 [ColorScheme] 动态生成配色
  /// 优先级：color > colorBuilder > JsonParseColor.from
  static JsonParseColor Function(ColorScheme scheme)? colorBuilder;

  /// 未自定义配色时，根据当前主题生成颜色
  static JsonParseColor resolveColor(BuildContext context) {
    final JsonParseColor? custom = _customColor;
    if (custom != null) return custom;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return colorBuilder?.call(scheme) ?? JsonParseColor.from(scheme);
  }

  /// text builder
  static JsonParseTextBuilder? textBuilder;

  /// toast builder
  static JsonParseToastBuilder? toastBuilder;

  /// 是否在每行末尾显示类型标识
  static bool showTypeBadge = true;

  final Map<dynamic, dynamic> json;
  final List<dynamic> list;
  final bool isList;

  /// 当前嵌套层级，由组件内部递归时递增
  final int depth;

  @override
  State<JsonParse> createState() => _JsonParseState();
}

class _JsonParseState extends State<JsonParse> {
  final Map<String, bool> _expanded = <String, bool>{};
  String? _activeFlag;

  JsonParseColor get _colors => JsonParse.resolveColor(context);

  @override
  Widget build(BuildContext context) {
    final JsonParseColor colors = _colors;
    final Color highlightColor = _highlightColor(colors);
    final Color arrowColor = colors.arrow ?? Theme.of(context).colorScheme.outline;
    final List<Widget> rows = <Widget>[];
    final List<MapEntry<dynamic, dynamic>> entries = widget.json.entries.toList();
    for (int index = 0; index < entries.length; index++) {
      final MapEntry<dynamic, dynamic> entry = entries[index];
      final String flag = '$index:${entry.key}';
      final bool expandable = _isExpandable(entry.value);
      final bool expanded = _expanded[flag] ?? false;
      rows.add(_buildRow(colors, highlightColor, arrowColor, flag, entry.key, entry.value, expandable, expanded));
      if (expandable && expanded) {
        rows.add(_buildChildren(context, entry.value));
      }
    }
    return Material(
      type: MaterialType.transparency,
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
      ),
    );
  }

  Widget _buildRow(
    JsonParseColor colors,
    Color highlightColor,
    Color arrowColor,
    String flag,
    dynamic key,
    dynamic value,
    bool expandable,
    bool expanded,
  ) {
    final _JsonValue item = _valueOf(value, colors);
    final Color keyColor = value == null ? colors.keyContentNull : colors.key;
    return _JsonRowHighlight(
      key: ValueKey<String>(flag),
      highlightColor: highlightColor,
      selected: _activeFlag == flag,
      onTap: () => _onTap(flag, expandable, expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 20,
              child: expandable
                  ? AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(Icons.chevron_right, size: 18, color: arrowColor),
                    )
                  : const SizedBox.shrink(),
            ),
            GestureDetector(
              onDoubleTap: () => _copy(key.toString()),
              child: _buildText(keyColor, widget.isList ? '[$key]:' : '$key:', fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 6),
            Expanded(child: _buildValue(value, item)),
            if (JsonParse.showTypeBadge) ...<Widget>[
              const SizedBox(width: 6),
              _TypeBadge(label: item.type, color: item.color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValue(dynamic value, _JsonValue item) {
    return GestureDetector(
      onLongPress: item.copyable ? () => _copyValue(value) : null,
      child: Align(alignment: Alignment.topLeft, child: _buildText(item.color, item.text, maxLines: 12)),
    );
  }

  Widget _buildChildren(BuildContext context, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outlineVariant, width: 1)),
      ),
      child: value is List
          ? JsonParse.list(value, depth: widget.depth + 1)
          : JsonParse(value as Map<dynamic, dynamic>, depth: widget.depth + 1),
    );
  }

  Widget _buildText(Color color, String text, {int? maxLines, FontWeight fontWeight = FontWeight.w400}) {
    final JsonParseTextBuilder? builder = JsonParse.textBuilder;
    if (builder != null) return builder(color, text);
    return Text(
      text,
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: TextStyle(color: color, fontFamily: 'monospace', fontSize: 13, height: 1.35, fontWeight: fontWeight),
    );
  }

  _JsonValue _valueOf(dynamic value, JsonParseColor colors) {
    if (value == null) return _JsonValue('null', colors.typeNull, 'NULL', copyable: false);
    if (value is String) return _JsonValue('"$value"', colors.typeString, 'STR');
    if (value is int) return _JsonValue(value.toString(), colors.typeNum, 'INT');
    if (value is num) return _JsonValue(value.toString(), colors.typeNum, 'NUM');
    if (value is bool) return _JsonValue(value.toString(), colors.typeBool, 'BOOL');
    if (value is TypedData) {
      return _JsonValue('<${value.runtimeType}>[${value.lengthInBytes}]', colors.typeList, 'BYTES', copyable: false);
    }
    if (value is List) {
      return _JsonValue('<${value.runtimeType}>[${value.length}]${_depthHint()}', colors.typeList, 'LIST');
    }
    if (value is Map) return _JsonValue('Map [${value.length}]${_depthHint()}', colors.typeMap, 'MAP');
    return _JsonValue('Object', colors.typeObject, 'OBJ', copyable: false);
  }

  /// 达到 [JsonParse.maxDepth] 时提示不再继续展开
  String _depthHint() => widget.depth >= JsonParse.maxDepth ? ' · max depth' : '';

  bool _isExpandable(dynamic value) {
    if (widget.depth >= JsonParse.maxDepth) return false;
    return (value is Map && value.isNotEmpty) || (value is List && value.isNotEmpty && value is! TypedData);
  }

  Color _highlightColor(JsonParseColor colors) {
    final Color? custom = colors.highlight;
    if (custom != null) return custom;
    final ThemeData theme = Theme.of(context);
    return theme.colorScheme.primary.withValues(alpha: theme.brightness == Brightness.dark ? 0.16 : 0.07);
  }

  void _onTap(String flag, bool expandable, bool expanded) {
    setState(() {
      _activeFlag = _activeFlag == flag ? null : flag;
      if (expandable) _expanded[flag] = !expanded;
    });
  }

  void _copyValue(dynamic value) {
    String text;
    if (value is Map || value is List) {
      try {
        text = jsonEncode(value);
      } catch (_) {
        text = value.toString();
      }
    } else {
      text = value.toString();
    }
    _copy(text);
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    JsonParse.toastBuilder?.call(text);
  }
}

class _JsonRowHighlight extends StatefulWidget {
  const _JsonRowHighlight({
    super.key,
    required this.highlightColor,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final Color highlightColor;
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_JsonRowHighlight> createState() => _JsonRowHighlightState();
}

class _JsonRowHighlightState extends State<_JsonRowHighlight> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _hovered || widget.selected;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: highlighted ? widget.highlightColor : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          splashColor: widget.highlightColor,
          highlightColor: Colors.transparent,
          child: widget.child,
        ),
      ),
    );
  }
}

class _JsonValue {
  const _JsonValue(this.text, this.color, this.type, {this.copyable = true});

  final String text;
  final Color color;
  final String type;
  final bool copyable;
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(
      color: color,
      fontSize: 9,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      height: 1.3,
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: style),
    );
  }
}
