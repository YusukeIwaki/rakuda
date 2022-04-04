# 🐫 rakuda (ラクだ！)

rakuda is a quick and dirty HTTP API client factory for Dart.
The generated API client binary can be easily distributed to your collegue :)

## Overview

Write your own client,

```dart
// petstore.dart

import 'package:rakuda/rakuda.dart';

void main(List<String> args) async {
  await createJSONClient(
    args,
    baseURL: 'https://petstore.swagger.io/v2',
  );
}
```

and compile it,

```
$ dart compile exe petstore.dart -o petstore
```

then enjoy!

```
$ ./petstore GET /pet/2
{"id":2,"category":{"id":7,"name":"drake"},"name":"shrimp","photoUrls":["string"],"tags":[{"id":0,"name":"string"}],"status":"sold"}

$ echo '{"id": 2, "name": "xx"}' | ./petstore PUT /pet
{"id":2,"name":"xx","photoUrls":[],"tags":[]}
```

## Features

### Create client

```dart
  await createJSONClient(
    args,
    baseURL: 'https://petstore.swagger.io/v2',
    interceptors: [], // [] by default.
    printResponse: true, // automarically print the response body. true by default.
  );
```

`createJSONClient` just add 2 headers: `Accept: application/json` and `Content-Type: application/json`.

If you want to create more detailed client, use `buildRequestFromArgs` and `RequestContext` instead.

```dart
  final request = await buildRequestFromArgs(arguments);
  final context = RequestContext(
    baseURL: 'https://petstore.swagger.io/v2',
    interceptors: [],
  );
  final response = await context.executeRequest(request);
```

### Interceptor

Authentication process or logging can be implemented with Interceptor.

```dart
Future<Response> logging(PerformRequest performRequest, Request request) async {
  print(">> ${request.method} ${request.path}");
  final response = await performRequest(request);
  print(">> HTTP ${response.status}");
  final body = response.body;
  if (body != null) {
    print(body);
  }
  return response;
}

void main(List<String> args) async {
  await createJSONClient(
    args,
    baseURL: 'https://petstore.swagger.io/v2',
    interceptors: [logging],
    printResponse: false,
  );
}
```

```
$ ./petstore GET /pet/3
>> GET /pet/3
>> HTTP 200
{"id":3,"category":{"id":0,"name":"string"},"name":"juanalberto","photoUrls":["string"],"tags":[{"id":0,"name":"carros"}],"status":"pending"}
```

For more complex implementation, refer the example of androidmanagement-v1 client: https://github.com/YusukeIwaki/rakuda-androidamanagement-api/blob/main/bin/androidmanagement.dart

## Usage of the generated client

rakuda is strongly inpired by [HTTPie](https://httpie.io/) and provides user-friendly CLI argument parser.

```
$ ./petstore GET /pet/2
$ ./github GET /search/repositories q=rakuda
$ ./myservice GET /me Authorization:Bearer $ACCESS_TOKEN
```

Note that **no `"` is required** in `Authorization:Bearer $ACCESS_TOKEN`. rakuda automatically detects the end of the header value even with space.

### Send body from stdin

```
$ echo '{"name": "YusukeIwaki"}' | ./myservice POST /users
```

### Send body from file

Use `@body=path/to/file`.

```
# Get data
$ ./myservice GET /users/3 > YusukeIwaki.json

# Edit it
$ vi YusukeIwaki.json

# Update with it!
$ ./myservice PUT /users/3 @body=YusukeIwaki.json
```

This works as well as `$ cat YusukeIwaki.json | ./myservice PUT /users/3`.

### Specify query parameter

Just list `name=value`.

```
$ ./github GET /search/repositories q=rakuda dart sort=stars
```

Note that rakuda automatically detects the end of the value even with space. The value of the 'q' parameter above is 'rakuda dart'.

### Specify additional headers

Just list `name:value`.

```
$ ./myservice GET /me Authorization:Bearer my-token-value
```

Note that rakuda automatically detects the end of the header value even with space. The value of the authorization header above is 'Bearer my-token-value'.

## Contributing

Contributions are welcome!

Here is a curated list of how you can help:

- Report bugs and scenarios that are difficult to implement
- Report parts of the documentation that are unclear
- Update the documentation / add examples
- Implement new features by making a pull-request.
