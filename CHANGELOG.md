## 2.1.0

* Rename `ExtendedDio` to `FlDio`, and `Extended*` types to `Fl*`: `ExtendedResponse` → `FlResponse`, `ExtendedDioMixin` → `FlDioMixin`, `ExtendedDioForNative` → `FlDioForNative`, `ExtendedDioForBrowser` → `FlDioForBrowser`, `toExtendedResponse` → `toFlResponse`, `generalExtendedResponse` → `generalFlResponse`
* Example app display name is now `FlDio` on iOS and Web
* Requires Flutter 3.47.0+ and Dart 3.13.0+
* Update dio to 5.11.1 and dio_web_adapter to 2.2.2
* `FlDio.clone()` now returns a `FlDio` instead of a plain `Dio`
* `FlResponse` fills `cookie` from `Set-Cookie` on both success and error paths
* `FlResponse.mergeDioException` keeps `data`, `statusCode`, `statusMessage`, `headers`, `redirects`, `extra` and `isRedirect` from the original response
* `RequestOptions.toMap()` keeps `Map`/`List` data as objects (other payloads are stringified), reports timeouts in milliseconds and uses `ResponseType.name`
* `Response.toMap()` and `FlResponse.toMap()` keep `Map`, `List` and primitive data as-is instead of returning the runtime type; byte payloads are summarized
* Improve `LoggerInterceptor` output: pretty JSON, request duration and FormData summaries; request and response headers are redacted by default via `redactHeaders`
* Improve `DebuggerInterceptor`: method/status badges, pending state, request count, empty state, a refreshed detail panel with segmented tabs and the error tab; keeps the latest 100 records by default and evicts completed records first; enabled only in debug/profile mode
* Improve `JsonParse`: colors derived from `Theme.colorScheme` (follows light/dark and seed changes), row highlight and type badges, monospace typography, animated expansion, nested guides, configurable key colors and a `maxDepth` guard against circular structures
* Fix `toStorageUnit` rounding for TB and PB values and reimplement it without large integer products
* Fix infinite recursion in `Uri.toMap()` for `data:` URIs
* Fix `dioLog` dropping messages that are exactly 800 characters long and splitting surrogate pairs
* Use `dart.library.js_interop` for web conditional imports so dart2wasm builds work
* Allow `setCookies` to return `null` and skip writing request headers
* Add unit tests for `toStorageUnit`, `FlResponse`, `FlDio.clone`, error merging and `CookiesInterceptor`
* Revamp the example app with request, error handling, transfer, interceptor and JsonParse demos, plus light/dark switching
* Improve README and example documentation

## 1.6.0

* Update dio to 5.9.2

## 1.5.1

* Fix the display issue of `LoggerInterceptor` for bytes and streams
* Fix the issue of excessively long text display in `JsonParse`

## 1.5.0

* Add `UniversalHttpClientAdapter`,Create different adapters on web and native, and support
  parameter settings

## 1.4.0

* Update dio to 5.8.0

## 1.3.1

* Fix the display issue of `DebuggerInterceptor` for bytes and streams
* Fix the display issue of `LoggerInterceptor` for bytes and streams
* Fix click issue with `JsonParse` value

## 1.2.3

* Update dio
* `DebuggerInterceptor` support real-time refresh

## 1.2.1

* Add `requestDataToJson` `requestQueryParametersToJson` and `responseDataToJson` to the
  `LoggerInterceptor`
* Update dio

## 1.2.0

* Adding a static method for `toastBuilder` to `JsonParse`
* Optimize the UI style of `DebuggerInterceptor`
* Update dio

## 1.1.1

* Adding parameters and optimizing log output format for `LoggerInterceptor`
* Update dio

## 1.1.0

* Add `ExtraParamsInterceptor()`

## 1.0.0

* Redevelop FlDio,No more dio instances are created,It is the same as the Dio api, except that
  the try catch is no longer required

## 0.2.1

* Update dio

## 0.2.0

* Added `hideRequest` and `hideResponse` to `LoggerInterceptor` to request parameters or response
  data too much
* `filtered` changed to completely hide log, including request parameter printing, response
  parameter printing, and error printing

## 0.1.1

* Update dio

## 0.1.0

* Initial release.
