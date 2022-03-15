import 'package:http/http.dart' as http;

class Request {
  final String method;
  final String path;
  final List<MapEntry<String, String>> headers;
  final List<MapEntry<String, String>> queryParameters;
  final String? body;

  Request(
    this.method,
    this.path,
    this.headers,
    this.queryParameters,
    this.body,
  );

  /// Set extra HTTP header.
  /// When [name] already exists, the value is replaced with [value].
  void setHeader(String name, String value) {
    for (var i = 0; i < headers.length; i++) {
      final header = headers[i];
      if (header.key == name) {
        headers[i] = MapEntry(name, value);
        return;
      }
    }
    headers.add(MapEntry(name, value));
  }

  /// Replace queryParameters with [replace] function,
  /// for the entries which meets the [predicate] function.
  void replaceQueryParameter(
    bool Function(MapEntry<String, String> entry) predicate,
    MapEntry<String, String> Function(MapEntry<String, String> entry) replace,
  ) {
    for (var i = 0; i < queryParameters.length; i++) {
      if (predicate(queryParameters[i])) {
        queryParameters[i] = replace(queryParameters[i]);
      }
    }
  }
}

class Response {
  final int status;
  final List<MapEntry<String, String>> headers;
  final String? body;

  Response(this.status, this.headers, this.body);
}

typedef PerformRequest = Future<Response> Function(Request request);

typedef Interceptor = Future<Response> Function(
    PerformRequest performRequest, Request request);

String _normalizedBaseURLFor(String baseURL) {
  final uri = Uri.parse(baseURL);
  if (uri.path.endsWith('/')) {
    return uri
        .replace(
          path: uri.path.substring(0, uri.path.length - 1),
          query: null,
          fragment: null,
        )
        .toString();
  } else {
    return uri
        .replace(
          query: null,
          fragment: null,
        )
        .toString();
  }
}

class RequestContext {
  final String baseURL;
  final List<Interceptor> interceptors;
  RequestContext(this.baseURL, this.interceptors);

  Future<Response> _executeRequestInternal(Request request) async {
    final Map<String, String> queryParameters = request.queryParameters.fold(
      {},
      (previous, entry) {
        previous[entry.key] = entry.value;
        return previous;
      },
    );
    final url = Uri.parse('$baseURL${request.path}').replace(
      queryParameters: queryParameters,
    );

    // The logic for the code below is copied from http.get, http.pose, and so on.
    final client = http.Client();
    try {
      final httpRequest = http.Request(request.method, url);

      // add headers.
      httpRequest.headers.addEntries(request.headers);

      // add body if specified.
      final body = request.body;
      if (body != null) {
        httpRequest.body = body;
      }

      // perform request
      final streamedResponse = await client.send(httpRequest);
      final httpResponse = await http.Response.fromStream(streamedResponse);

      return Response(
        httpResponse.statusCode,
        httpResponse.headers.entries.toList(),
        httpResponse.body,
      );
    } finally {
      client.close();
    }
  }

  Future<Response> executeRequest(Request request) async {
    final PerformRequest wrapped = interceptors.fold(
      _executeRequestInternal,
      ((performRequest, interceptor) =>
          ((request) => interceptor(performRequest, request))),
    );
    return wrapped(request);
  }
}
