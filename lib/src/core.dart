library rakuda;

import 'dart:convert';
import 'dart:io';

import 'errors.dart';
import 'argparse.dart' as argparse;
import 'http.dart' as http;

/// Prepare almost zero-config JSON client.
/// This method
/// - parse CLI args
/// - execute HTTP request
/// - insert an interceptor for setting Accept and Content-Type header to application/json
/// - automarically print the response body if [printResponse]
Future<http.Response> createJSONClient(
  List<String> args, {
  required String baseURL,
  List<http.Interceptor> interceptors = const [],
  bool printResponse = true,
}) async {
  final requestContext = http.RequestContext(
    baseURL: baseURL,
    interceptors: <http.Interceptor>[
      injectHeadersForJsonRequest,
      ...interceptors,
    ],
  );
  final request = await buildRequestFromArgs(args);
  final response = await requestContext.executeRequest(request);

  if (printResponse) {
    final responseBody = response.body;
    if (responseBody != null) {
      stdout.writeln(responseBody);
    }
  }
  return response;
}

Future<http.Response> injectHeadersForJsonRequest(
    http.PerformRequest performRequest, http.Request request) {
  request
    ..setHeader('Accept', 'application/json')
    ..setHeader('Content-Type', 'application/json');
  return performRequest(request);
}

Future<http.Request> buildRequestFromArgs(List<String> args) async {
  final cliArgs = argparse.parseArguments(args);
  final cliArgsBodyParam = cliArgs.magicParameters.body;
  String? body;
  if (cliArgsBodyParam != null) {
    if (!stdin.hasTerminal) {
      // pipe input
      throw InvalidArgumentException(
          '@body cannot be specified when Pipe input is present');
    }
    body = await _readStreamAsString(
        File(cliArgsBodyParam).openRead().transform(utf8.decoder));
  } else if (!stdin.hasTerminal) {
    //pipe input
    body = await _readStreamAsString(stdin.transform(utf8.decoder));
  }

  return http.Request(
    cliArgs.method,
    cliArgs.path,
    cliArgs.headers,
    cliArgs.queryParameters,
    body,
  );
}

Future<String> _readStreamAsString(Stream<String> stream) async {
  final buffer = StringBuffer();
  await stream.forEach((chunk) {
    buffer.write(chunk);
  });
  return buffer.toString();
}
