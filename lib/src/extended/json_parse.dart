import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonParseColor {
  JsonParseColor({
    this.typeMap = Colors.grey,
    this.typeList = Colors.grey,
    this.typeNull = Colors.grey,
    this.typeNum = Colors.teal,
    this.typeString = Colors.redAccent,
    this.typeBool = Colors.blue,
    this.typeObject = Colors.grey,
    this.arrow,
    this.key = Colors.purpleAccent,
    this.keyContentNull = Colors.grey,
  });

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
}

typedef JsonParseTextBuilder = Widget Function(Color color, String content);
typedef JsonParseToastBuilder = void Function(String content);

class JsonParse extends StatefulWidget {
  JsonParse(this.json, {super.key})
      : list = <dynamic>[],
        isList = false;

  JsonParse.list(this.list, {super.key})
      : json = list.asMap(),
        isList = true;

  /// text color
  static JsonParseColor color = JsonParseColor();

  /// text builder
  static JsonParseTextBuilder? textBuilder;

  /// toast builder
  static JsonParseToastBuilder? toastBuilder;

  final Map<dynamic, dynamic> json;
  final List<dynamic> list;
  final bool isList;

  @override
  State<JsonParse> createState() => _JsonParseState();
}

class _JsonParseState extends State<JsonParse> {
  Map<String, bool> mapFlag = <String, bool>{};

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    widget.json.entries.map((MapEntry<dynamic, dynamic> entry) {
      final dynamic key = entry.key;
      final dynamic content = entry.value;
      final List<Widget> row = [];
      if (isTap(content)) {
        row.add(Icon(
            (mapFlag[key.toString()]) ?? false
                ? Icons.arrow_drop_down_outlined
                : Icons.arrow_right_rounded,
            color: JsonParse.color.arrow,
            size: 22));
      } else {
        row.add(const SizedBox(width: 18));
      }
      row.addAll([
        GestureDetector(
            onDoubleTap: () {
              Clipboard.setData(ClipboardData(text: key.toString()));
            },
            child: buildItem(content == null ? Colors.grey : Colors.purple,
                widget.isList || isTap(content) ? '[$key]:' : ' $key :')),
        const SizedBox(width: 4),
        getValueWidget(content)
      ]);
      list.add(GestureDetector(
        onTap: !isTap(content)
            ? null
            : () {
                mapFlag[key.toString()] = !(mapFlag[key.toString()] ?? false);
                setState(() {});
              },
        child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, children: row)),
      ));
      list.add(const SizedBox(height: 4));
      if ((mapFlag[key.toString()]) ?? false) {
        list.add(getContentWidget(content));
      }
    }).toList();
    return SingleChildScrollView(child: Column(children: list));
  }

  Widget buildItem(Color color, String text) =>
      JsonParse.textBuilder?.call(color, text) ??
      Text(text, style: TextStyle(fontWeight: FontWeight.w400, color: color));

  Widget getContentWidget(dynamic content) => Padding(
      padding: const EdgeInsets.only(left: 10),
      child: content is List
          ? JsonParse.list(content)
          : content is Map<dynamic, dynamic>
              ? JsonParse(content)
              : JsonParse({content.runtimeType: content.toString()}));

  Widget getValueWidget(dynamic content) {
    String text = '';
    Color color = Colors.transparent;
    bool isToClipboard = false;
    if (content == null) {
      text = 'null';
      color = JsonParse.color.typeNull;
    } else if (content is num) {
      text = content.toString();
      color = JsonParse.color.typeNum;
      isToClipboard = true;
    } else if (content is String) {
      text = content;
      color = JsonParse.color.typeString;
      isToClipboard = true;
    } else if (content is bool) {
      text = content.toString();
      color = JsonParse.color.typeBool;
      isToClipboard = true;
    } else if (content is List) {
      text = content.isEmpty
          ? '[0]'
          : '<${content.runtimeType}>[${content.length}]';
      color = JsonParse.color.typeList;
    } else if (content is Map) {
      text = 'Map [${content.length}]';
      color = JsonParse.color.typeMap;
      isToClipboard = true;
    } else {
      text = 'Object';
      color = JsonParse.color.typeObject;
    }
    return Expanded(
        child: GestureDetector(
            onLongPress: isToClipboard
                ? () {
                    Clipboard.setData(ClipboardData(text: content.toString()));
                    JsonParse.toastBuilder?.call(content.toString());
                  }
                : null,
            child: JsonParse.textBuilder?.call(color, text) ??
                Text(text,
                    style: TextStyle(color: color, fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left)));
  }

  bool isTap(dynamic content) =>
      (content is Map && content.isNotEmpty) ||
      (content is List && content.isNotEmpty && content is! TypedData);
}
