import 'errors.dart';

class MagicParameters {
  String? body;

  bool get isEmpty => body == null;
}

class ParseResult {
  final String method;
  final String path;
  final List<MapEntry<String, String>> queryParameters;
  final List<MapEntry<String, String>> headers;
  final MagicParameters magicParameters;

  ParseResult(
    this.method,
    this.path,
    this.queryParameters,
    this.headers,
    this.magicParameters,
  );
}

const supportedMethods = [
  'GET',
  'POST',
  'PATCH',
  'PUT',
  'DELETE',
];

String _validatedMethodFor(List<String> args) {
  if (args.isEmpty) {
    throw InvalidArgumentException(
        'HTTP method (GET, POST, ...) must be specified');
  }
  final method = args.first;
  if (!supportedMethods.contains(method)) {
    throw InvalidArgumentException(
        'HTTP method must be one of $supportedMethods');
  }
  return method;
}

String _validatedPathFor(List<String> args) {
  if (args.length < 2) {
    throw InvalidArgumentException('path must be specified');
  }
  final path = args[1];
  if (!path.startsWith('/')) {
    throw InvalidArgumentException('path must start with "/"');
  }
  return path;
}

class _ParamsAndHeaders {
  final List<MapEntry<String, String>> queryParameters;
  final List<MapEntry<String, String>> magicParameters;
  final List<MapEntry<String, String>> headers;

  _ParamsAndHeaders(
    this.queryParameters,
    this.magicParameters,
    this.headers,
  );
}

_ParamsAndHeaders _parseParamsAndHeaders(List<String> args) {
  final queryParameters = <MapEntry<String, String>>[];
  final magicParameters = <MapEntry<String, String>>[];
  final headers = <MapEntry<String, String>>[];

  List<MapEntry<String, String>>? cur;
  if (args.length >= 3) {
    final paramRegExp = RegExp(r'^(@?[a-zA-Z_]+)=');
    final headerRegExp = RegExp(r'^([a-zA-Z_-]+):');

    for (var i = 2; i < args.length; i++) {
      final arg = args[i];

      final paramMatch = paramRegExp.firstMatch(arg);
      if (paramMatch != null) {
        final name = paramMatch.group(1)!;
        final value = arg.substring(paramMatch.end);

        if (name.startsWith('@')) {
          cur = magicParameters;
        } else {
          cur = queryParameters;
        }

        cur.add(MapEntry(name, value));
        continue;
      }

      final headerMatch = headerRegExp.firstMatch(arg);
      if (headerMatch != null) {
        final name = headerMatch.group(1)!;
        final value = arg.substring(headerMatch.end);

        cur = headers;
        cur.add(MapEntry(name, value));
        continue;
      }

      if (cur == null || cur.isEmpty) {
        throw InvalidArgumentException(
            'Unable to parse args: ${args.join(' ')}');
      }
      final last = cur.removeLast();
      if (last.value.isEmpty) {
        cur.add(MapEntry(last.key, arg));
      } else {
        cur.add(MapEntry(last.key, '${last.value} $arg'));
      }
    }
  }

  return _ParamsAndHeaders(
    queryParameters,
    magicParameters,
    headers,
  );
}

/// Typically command line arguments arguments are passed to [args]
///
/// This parser allow us to specify HTTP request fluently like GET /search q=dart Authorization: Basic aXdha2k6MTIzNDUK
/// Note that no " or ' is required.
///
/// ['GET', '/search', 'q=dart', 'Authorization:' 'Basic' 'aXdha2k6MTIzNDUK']
/// will be parsed like this: method=GET, path=/search, queryParameters=[[q, dart]], headers: [[Authorization, 'Basic aXdha2k6MTIzNDUK']]
///
/// Also this method allow special parameters which starts with '@'.
/// - @body=/path/to/file.json adds request body from the specified file.
///
ParseResult parseArguments(List<String> args) {
  final method = _validatedMethodFor(args);
  final pathWithQuery = _validatedPathFor(args);
  final paramsAndHeaders = _parseParamsAndHeaders(args);

  final uri = Uri.parse(pathWithQuery);
  final queryParameters = <MapEntry<String, String>>[];
  uri.queryParametersAll.forEach((name, values) {
    for (final value in values) {
      queryParameters.add(MapEntry(name, value));
    }
  });
  queryParameters.addAll(paramsAndHeaders.queryParameters);

  final magicParameters = MagicParameters();
  for (final entry in paramsAndHeaders.magicParameters) {
    if (entry.key == '@body') {
      magicParameters.body = entry.value;
    } else {
      throw InvalidArgumentException('Unknown parameter: @${entry.key}');
    }
  }

  return ParseResult(
    method,
    uri.path,
    queryParameters,
    paramsAndHeaders.headers,
    magicParameters,
  );
}
