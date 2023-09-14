import 'package:fl_dio/src/universal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JsonParse extends StatefulWidget {
  JsonParse(this.json, {super.key})
      : list = <dynamic>[],
        isList = false;

  JsonParse.list(this.list, {super.key})
      : json = list.asMap(),
        isList = true;

  final Map<dynamic, dynamic> json;
  final List<dynamic> list;
  final bool isList;

  @override
  State<JsonParse> createState() => _JsonParseState();
}

class _JsonParseState extends State<JsonParse> {
  Map<String, bool> mapFlag = <String, bool>{};

  @override
  Widget build(BuildContext context) => Universal(
      isScroll: true,
      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children);

  List<Widget> get children {
    final List<Widget> list = [];
    widget.json.entries.map((MapEntry<dynamic, dynamic> entry) {
      final dynamic key = entry.key;
      final dynamic content = entry.value;
      final List<Widget> row = [];
      if (isTap(content)) {
        row.add(Icon(
            (mapFlag[key.toString()]) ?? false
                ? Icons.arrow_right_rounded
                : Icons.arrow_drop_down_outlined,
            size: 22));
      } else {
        row.add(const SizedBox(width: 18));
      }
      row.addAll([
        GestureDetector(
            onDoubleTap: () {
              Clipboard.setData(ClipboardData(text: key.toString()));
            },
            child: Text(widget.isList || isTap(content) ? '[$key]:' : ' $key :',
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: content == null ? Colors.grey : Colors.purple))),
        const SizedBox(width: 4),
        getValueWidget(content)
      ]);
      list.add(Universal(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.start,
          onTap: !isTap(content)
              ? null
              : () {
                  mapFlag[key.toString()] = !(mapFlag[key.toString()] ?? false);
                  setState(() {});
                },
          children: row));
      list.add(const SizedBox(height: 4));
      if ((mapFlag[key.toString()]) ?? false) {
        list.add(getContentWidget(content));
      }
    }).toList();
    return list;
  }

  Widget getContentWidget(dynamic content) => content is List
      ? JsonParse.list(content)
      : content is Map<String, dynamic>
          ? JsonParse(content)
          : JsonParse({content.runtimeType: content.toString()});

  Widget getValueWidget(dynamic content) {
    String text = '';
    Color color = Colors.transparent;
    bool isToClipboard = false;
    if (content == null) {
      text = 'null';
      color = Colors.grey;
    } else if (content is num) {
      text = content.toString();
      color = Colors.teal;
      isToClipboard = true;
    } else if (content is String) {
      text = content;
      color = Colors.redAccent;
      isToClipboard = true;
    } else if (content is bool) {
      text = content.toString();
      color = Colors.blue;
      isToClipboard = true;
    } else if (content is List) {
      text = content.isEmpty
          ? '[0]'
          : '<${content.runtimeType.toString()}>[${content.length}]';
      color = Colors.grey;
    } else if (content is Map) {
      text = 'Map';
      color = Colors.grey;
      isToClipboard = true;
    } else {
      text = 'Object';
      color = Colors.grey;
    }
    return Universal(
        expanded: true,
        onTap: isToClipboard
            ? () {
                Clipboard.setData(ClipboardData(text: content.toString()));
              }
            : null,
        child: Text(text,
            style: TextStyle(color: color, fontWeight: FontWeight.w400),
            textAlign: TextAlign.left));
  }

  bool isTap(dynamic content) => !(content == null ||
      content is int ||
      content is String ||
      content is bool ||
      content is double ||
      (content is List && content.isEmpty));
}
