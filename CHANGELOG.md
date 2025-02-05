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

* Add `requestDataToJson` `requestQueryParametersToJson` and `responseDataToJson` to the `LoggerInterceptor`
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

* Redevelop ExtendedDio,No more dio instances are created,It is the same as the Dio api, except that
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
