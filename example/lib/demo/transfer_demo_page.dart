import 'package:example/demo/demo_dio.dart';
import 'package:example/demo/theme_mode.dart';
import 'package:fl_dio/fl_dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TransferDemoPage extends StatefulWidget {
  const TransferDemoPage({super.key});

  @override
  State<TransferDemoPage> createState() => _TransferDemoPageState();
}

class _TransferDemoPageState extends State<TransferDemoPage> {
  static const String _downloadUrl = 'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';
  static const String _uploadUrl = 'https://jsonplaceholder.typicode.com/posts';

  bool _downloadBusy = false;
  bool _uploadBusy = false;
  double? _downloadProgress;
  double? _uploadProgress;
  CancelToken? _downloadCancelToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('下载与上传'), actions: const <Widget>[ThemeToggleButton()]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          const DemoHint(
            '下载和上传都支持进度回调与 CancelToken。'
            '原生端下载会写入临时目录，Web 端改为读取字节流，不会写文件。',
          ),
          const SizedBox(height: 20),
          _card(
            title: '下载',
            subtitle: _downloadUrl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 10,
                  children: <Widget>[
                    FilledButton.icon(
                      onPressed: _downloadBusy ? null : _download,
                      icon: const Icon(Icons.download),
                      label: const Text('开始下载'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _downloadCancelToken == null ? null : _cancelDownload,
                      icon: const Icon(Icons.stop_circle_outlined),
                      label: const Text('取消'),
                    ),
                  ],
                ),
                if (_downloadBusy) ...<Widget>[const SizedBox(height: 14), _progress('下载进度', _downloadProgress)],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _card(
            title: '上传',
            subtitle: 'MultipartFile.fromBytes + onSendProgress',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _uploadBusy ? null : _upload,
                  icon: const Icon(Icons.upload),
                  label: const Text('上传 1 MB 文件'),
                ),
                if (_uploadBusy) ...<Widget>[const SizedBox(height: 14), _progress('上传进度', _uploadProgress)],
              ],
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
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _progress(String label, double? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LinearProgressIndicator(value: value),
        const SizedBox(height: 6),
        Text(
          value == null ? '$label ...' : '$label ${(value * 100).toStringAsFixed(0)}%',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Future<void> _download() async {
    final CancelToken token = CancelToken();
    setState(() {
      _downloadBusy = true;
      _downloadProgress = 0;
      _downloadCancelToken = token;
    });

    void onProgress(int received, int total) {
      if (!mounted) return;
      setState(() {
        _downloadProgress = total > 0 ? received / total : null;
      });
    }

    if (kIsWeb) {
      final FlResponse<List<int>> response = await demoDio.get<List<int>>(
        _downloadUrl,
        options: Options(responseType: ResponseType.bytes),
        cancelToken: token,
        onReceiveProgress: onProgress,
      );
      if (!mounted) return;
      setState(() {
        _downloadBusy = false;
        _downloadCancelToken = null;
      });
      if (response.exception != null) {
        await showFlResponse(context, response);
      } else {
        showMessage('下载完成：${response.data?.length ?? 0} 字节（Web 端不写入文件）');
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final String savePath = '${dir.path}/fl_dio_demo.jpg';
    final FlResponse<dynamic> response = await demoDio.download(
      _downloadUrl,
      savePath,
      cancelToken: token,
      onReceiveProgress: onProgress,
    );
    if (!mounted) return;
    setState(() {
      _downloadBusy = false;
      _downloadCancelToken = null;
    });
    if (response.exception != null) {
      await showFlResponse(context, response);
    } else {
      showMessage('已保存到 $savePath');
    }
  }

  void _cancelDownload() {
    _downloadCancelToken?.cancel('用户取消下载');
  }

  Future<void> _upload() async {
    setState(() {
      _uploadBusy = true;
      _uploadProgress = 0;
    });

    final Uint8List bytes = Uint8List.fromList(List<int>.generate(1024 * 1024, (int index) => 65 + index % 26));
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'name': 'fl_dio demo',
      'file': MultipartFile.fromBytes(bytes, filename: 'fl_dio_demo.txt', contentType: MediaType('text', 'plain')),
    });

    final FlResponse<Map<String, dynamic>> response = await demoDio.post<Map<String, dynamic>>(
      _uploadUrl,
      data: formData,
      onSendProgress: (int sent, int total) {
        if (!mounted) return;
        setState(() {
          _uploadProgress = total > 0 ? sent / total : null;
        });
      },
    );
    if (!mounted) return;
    setState(() => _uploadBusy = false);
    await showFlResponse(context, response);
  }
}
