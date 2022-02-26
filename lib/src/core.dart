library rakuda;

import 'dart:convert';
import 'dart:io';

import 'errors.dart';
import 'argparse.dart' as argparse;
import 'http.dart' as http;

Future<http.Response> executeHTTPRequest(
  List<String> args,
  String baseURL,
  List<http.Interceptor> interceptors,
) async {
  final request = await _buildRequestFromArgs(args);
  return await http.executeRequest(request, baseURL, interceptors);
}

Future<http.Request> _buildRequestFromArgs(List<String> args) async {
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
