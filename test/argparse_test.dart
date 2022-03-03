import 'package:test/test.dart';

import '../lib/src/argparse.dart';

void main() {
  test('parse Simple URL', () {
    final result = parseArguments('GET /current_user'.split(' '));
    expect(result.method, equals('GET'));
    expect(result.path, equals('/current_user'));
    expect(result.headers, isEmpty);
    expect(result.queryParameters, isEmpty);
    expect(result.magicParameters, isEmpty);
  });

  test('parse URL with query parameters', () {
    final result = parseArguments('GET /search?q=日本語&page=12'.split(' '));
    expect(result.method, equals('GET'));
    expect(result.path, equals('/search'));
    expect(result.headers, isEmpty);
    expect(result.queryParameters, hasLength(2));
    expect(
      result.queryParameters.map((entry) => entry.toString()),
      containsAll([
        MapEntry('q', '日本語').toString(),
        MapEntry('page', '12').toString(),
      ]),
    );
    expect(result.magicParameters, isEmpty);
  });

  test('parse additional query parameters', () {
    final result = parseArguments('GET /search q=日本語 English'.split(' '));
    expect(result.method, equals('GET'));
    expect(result.path, equals('/search'));
    expect(result.headers, isEmpty);
    expect(result.queryParameters, hasLength(1));
    expect(
      result.queryParameters.first.toString(),
      equals(MapEntry('q', '日本語 English').toString()),
    );
    expect(result.magicParameters, isEmpty);
  });

  test('parse additional headers', () {
    final result = parseArguments(
        'GET /current_user Authorization: Bearer xxxxxxxxx X-CUSTOM-ID:Custom 1 2 3'
            .split(' '));
    expect(result.method, equals('GET'));
    expect(result.path, equals('/current_user'));
    expect(result.headers, hasLength(2));
    expect(
      result.headers.map((entry) => entry.toString()),
      containsAll([
        MapEntry('Authorization', 'Bearer xxxxxxxxx').toString(),
        MapEntry('X-CUSTOM-ID', 'Custom 1 2 3').toString(),
      ]),
    );
    expect(result.queryParameters, isEmpty);
    expect(result.magicParameters, isEmpty);
  });

  test('parse @body', () {
    final result =
        parseArguments('PUT /current_user @body=form data.json'.split(' '));
    expect(result.method, equals('PUT'));
    expect(result.path, equals('/current_user'));
    expect(result.headers, isEmpty);
    expect(result.queryParameters, isEmpty);
    expect(result.magicParameters.body, equals("form data.json"));
  });
}
