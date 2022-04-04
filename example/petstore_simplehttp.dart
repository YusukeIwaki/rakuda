import 'package:rakuda/rakuda.dart';

Future<Response> addJsonHeader(performRequest, request) async {
  request
    ..setHeader('User-Agent', 'Rakuda/0.1.0')
    ..setHeader('Content-Type', 'application/json');
  return await performRequest(request);
}

Future<Response> logging(performRequest, request) async {
  print(">> ${request.method} ${request.path}");
  final response = await performRequest(request);
  print(">> HTTP ${response.status}");
  final body = response.body;
  if (body != null) {
    print(body);
  }
  return response;
}

void main(List<String> arguments) async {
  await createSimpleHTTPClient(
    arguments,
    baseURL: 'https://petstore.swagger.io/v2',
    interceptors: [addJsonHeader, logging],
    printResponse: false,
  );
}
