## 0.2.2

- `injectHeadersForJsonRequest` is now available for appending headers 'Accept: application/json' and 'Content-Type: application/json'.

## 0.2.1

- Fix request interceptors to work.

## 0.2.0

- `RequestContext` and `buildResponseFromArgs` are exposed. More detailed handling of HTTP can be implemented with them.

Breaking Changes:

- `createSimpleHTTPClient` is removed. Use `buildResponseFromArgs` and `RequestContext` instead.

## 0.1.1

- Add support for Linux.

## 0.1.0

- Initial version.
- Windows/macOS are supported.
