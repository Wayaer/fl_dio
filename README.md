# fl_dio

[![pub package](https://img.shields.io/pub/v/fl_dio.svg)](https://pub.dev/packages/fl_dio)
[![pub points](https://img.shields.io/pub/points/fl_dio)](https://pub.dev/packages/fl_dio/score)

FlDio is a wrapper around [`dio`](https://pub.dev/packages/dio) for Flutter. `FlDio` keeps the
same API as `Dio`, but every request resolves to a `FlResponse` instead of
throwing, so no `try/catch` is needed. The package also ships four interceptors,
a collapsible `JsonParse` viewer, a universal web/native adapter and a set of
convenient extensions.

- Dart `>=3.13.0`, Flutter `>=3.47.0`
- Android, iOS, macOS, Windows, Linux and Web
- [Live web example](https://wayaer.github.io/fl_dio/example/app/web/index.html#/)

## Features

- **No try/catch** — failures are returned as `FlResponse.exception`.
- **LoggerInterceptor** — formatted request / response / error logs with filters.
- **DebuggerInterceptor** — in-app request inspector with a draggable overlay.
- **CookiesInterceptor** — inject request cookies and read response cookies.
- **ExtraParamsInterceptor** — mutate header / query / path / data before a request.
- **JsonParse** — collapsible JSON viewer with copy-to-clipboard and theming.
- **UniversalHttpClientAdapter** — one configuration for web and native.
- **Extensions** — `toMap()` on responses, options, exceptions and URIs, plus `toStorageUnit()`.

## Install

```yaml
dependencies:
  fl_dio: ^2.1.0
```

```dart
import 'package:fl_dio/fl_dio.dart';
```

## Usage

### Requests

```dart
final FlDio dio = FlDio(
  BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
  ),
);

final FlResponse<Map<String, dynamic>> response =
    await dio.get<Map<String, dynamic>>('/posts/1');

if (response.exception != null) {
  // Nothing was thrown. Inspect the failure here.
  debugPrint('${response.type}');
  debugPrint('${response.statusCode}');
  debugPrint('${response.exception}');
} else {
  debugPrint('${response.data}');
}
```

`FlDio` mirrors every `Dio` method, including the `Uri` variants:

```dart
await dio.head('/posts/1');
await dio.getUri(Uri.parse('https://example.com/api'));
await dio.post('/posts', data: <String, dynamic>{'title': 'fl_dio'});
await dio.put('/posts/1', data: <String, dynamic>{'title': 'updated'});
await dio.patch('/posts/1', data: <String, dynamic>{'title': 'patched'});
await dio.delete('/posts/1');
await dio.download('https://example.com/file.zip', '/tmp/file.zip',
    onReceiveProgress: (int received, int total) {});
await dio.request('/posts', options: Options(method: 'POST'));
```

`dio.clone()` keeps the same behaviour and returns another `FlDio`.

### FlResponse

`FlResponse<T>` extends `Response<T>` and adds:

| Member | Description |
| --- | --- |
| `exception` | The caught `DioException` or any other error object. |
| `type` | `DioExceptionType` of the failure, e.g. `badResponse` or `connectionError`. |
| `cookie` | `Set-Cookie` values from the response, filled automatically when present. |

For HTTP errors, the original response is available on the exception:

```dart
final FlResponse<dynamic> response = await dio.get('/missing');

if (response.exception is DioException) {
  final DioException error = response.exception as DioException;
  debugPrint('${error.type}');                // badResponse
  debugPrint('${error.response?.statusCode}'); // 404
  debugPrint('${error.response?.data}');
}
```

### Interceptors

Interceptors are independent from `FlDio`; you can add them to any `Dio`
instance:

```dart
dio.interceptors.addAll(<Interceptor>[
  ExtraParamsInterceptor(),
  LoggerInterceptor(),
  DebuggerInterceptor(),
  CookiesInterceptor(),
]);
```

#### LoggerInterceptor

```dart
dio.interceptors.add(LoggerInterceptor(
  filtered: <String>['/health'],   // hide these APIs completely
  hideRequest: <String>['/upload'], // hide request data only
  hideResponse: <String>['/huge'],  // hide response data only
  printResponseHeader: true,
  printErrorResponse: true,
  responseToJson: true,
));
```

| Parameter | Default | Description |
| --- | --- | --- |
| `filtered` | `[]` | APIs containing any of these strings are not logged at all. |
| `hideRequest` | `[]` | Hide request data for matching APIs. |
| `hideResponse` | `[]` | Hide response data for matching APIs. |
| `printResponseHeader` | `false` | Print response headers. |
| `printErrorResponse` | `false` | Print the error response body. |
| `requestQueryParametersToJson` | `true` | JSON-encode `Map` query parameters. |
| `requestDataToJson` | `true` | JSON-encode `Map` request data. |
| `requestHeaderToJson` | `true` | JSON-encode `Map` request headers. |
| `responseToJson` | `true` | JSON-encode `Map` response data. |
| `isPrintBytes` | `false` | Print byte payloads instead of their size. |
| `prettyJson` | `true` | Pretty-print `Map`/`List` payloads with two-space indentation. |
| `printDuration` | `true` | Print the request duration on response and error logs. |
| `redactHeaders` | `authorization`, `cookie`, `set-cookie`, `proxy-authorization` | Header names masked as `***` in logs; matching is case-insensitive. Set to `<String>[]` to disable. |

Logs are written with `debugPrint` and only appear in debug/profile mode.

#### DebuggerInterceptor

The overlay needs a `NavigatorKey` before `runApp`:

```dart
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  DebuggerInterceptorHelper().navigatorKey = navigatorKey;

  final FlDio dio = FlDio()
    ..interceptors.add(DebuggerInterceptor());

  runApp(MaterialApp(navigatorKey: navigatorKey));
}
```

After a response the interceptor shows a draggable bug icon with a request count.
The inspector lists requests with method and status badges, a pending spinner and
the request time, size and duration; tap a card to inspect the request, response
and error JSON. The latest 100 records are kept by default; change
`DebuggerInterceptorHelper().maxRecords` to adjust the limit (completed records
are evicted before pending ones). Open the inspector with
`DebuggerInterceptorHelper().showDebugger()`, show or hide the icon with
`show()` / `hide()`.

The interceptor is enabled only in debug and profile mode by default, so release
builds record nothing. Pass `DebuggerInterceptor(enabled: true)` to force it on.

#### CookiesInterceptor

```dart
dio.interceptors.add(CookiesInterceptor(
  setCookies: (RequestOptions options) => <String, dynamic>{
    'Cookie': 'token=fl_dio; source=demo',
  },
  getCookies: (Response<dynamic> response) {
    debugPrint('${response.headers.map['set-cookie']}');
  },
));
```

`setCookies` returns the headers to merge into the request (return `null` or an
empty map to skip); `getCookies` is called for successful and failed responses.

Browsers forbid scripts from setting the `Cookie` request header or reading
`Set-Cookie`. On the web use `withCredentials: true` and let the browser manage
cookies instead.

#### ExtraParamsInterceptor

```dart
dio.interceptors.add(ExtraParamsInterceptor(
  onExtraHeader: (Uri uri, Map<String, dynamic> headers) => <String, dynamic>{
    ...headers,
    'X-Token': 'token',
  },
  onExtraParams: (Uri uri, Map<String, dynamic> params) => <String, dynamic>{
    ...params,
    'source': 'fl_dio',
  },
  onExtraPath: (Uri uri) => uri.path.startsWith('/v1') ? null : '/v1${uri.path}',
  onExtraData: (Uri uri, dynamic data) => data,
));
```

A returned map replaces the original header/query map; return `null` to leave it
unchanged.

### JsonParse

```dart
JsonParse(map);
JsonParse.list(list);
```

Rows highlight on hover or tap, and each row ends with a type badge (`STR`, `INT`,
`NUM`, `BOOL`, `NULL`, `MAP`, `LIST`, `BYTES`, `OBJ`); set
`JsonParse.showTypeBadge = false` to hide the badges. Tap the arrow to expand a
`Map`/`List`, long-press a value to copy it (maps and lists are copied as JSON),
and double-tap a key to copy that.

Nested maps and lists expand up to `JsonParse.maxDepth` levels (default `20`),
which also guards against circular references.

By default the palette is derived from `Theme.of(context).colorScheme`: keys use
`onSurface`, strings use `primary`, numbers use `tertiary`, booleans use
`secondary`, and null / structural values use `outline` / `onSurfaceVariant`.
Changing `seedColor` or switching between light and dark updates the JSON colors
automatically. Override individual colors while keeping the theme:

```dart
JsonParse.colorBuilder = (ColorScheme scheme) =>
    JsonParseColor.from(scheme).copyWith(typeString: Colors.redAccent);
```

Use `JsonParse.color` for a fixed palette that no longer follows the theme, and
customize the text and copy toast if needed:

```dart
JsonParse.color = JsonParseColor(
  typeString: Colors.redAccent,
  highlight: Colors.amber.withAlpha(20)
);
JsonParse.textBuilder = (Color color, String content) => Text(
      content,
      style: TextStyle(color: color, fontFamily: 'monospace')
    );
JsonParse.toastBuilder = (String content) => debugPrint('Copied: $content');
```

### UniversalHttpClientAdapter

Use one adapter setup on every platform:

```dart
dio.httpClientAdapter = UniversalHttpClientAdapter(
  // Web
  withCredentials: true,

  // Native only, ignored on the web
  createHttpClient: () => HttpClient()..connectionTimeout = const Duration(seconds: 10),
  validateCertificate: (X509Certificate? certificate, String host, int port) => true,
).create();
```

`createHttpClient` and `validateCertificate` require `dart:io` and are ignored on
the web, where `withCredentials` is applied to the browser adapter.

### Extensions

```dart
final Map<String, dynamic> responseMap = response.toMap();
final Map<String, dynamic> requestMap = response.requestOptions.toMap();
final Map<String, dynamic> errorMap =
    (response.exception as DioException).toMap();

debugPrint(1536.toStorageUnit()); // 1.50 KB
```

`toMap()` is available on `Response`, `FlResponse`, `DioException`,
`RequestOptions`, `Uri` and `UriData`.

## Platform notes

- **Web cookies** — browser security prevents scripts from reading `Set-Cookie`
  or writing the `Cookie` header; use `withCredentials` instead.
- **Web downloads** — `dio.download` writes to the file system, which exists only
  on native platforms. On the web request `ResponseType.bytes` instead.
- **Debugger overlay** — requires `DebuggerInterceptorHelper().navigatorKey`.
- **Logging** — `dioLog` prints only in debug and profile mode.

## Example

The [example app](https://github.com/Wayaer/fl_dio/tree/main/example) contains
runnable demos for:

- requests and error handling without `try/catch`
- download / upload progress and cancellation
- all four interceptors
- the `JsonParse` viewer

Try it on the web: [wayaer.github.io/fl_dio](https://wayaer.github.io/fl_dio/example/app/web/index.html#/)

## License

[MIT](https://github.com/Wayaer/fl_dio/blob/main/LICENSE)
