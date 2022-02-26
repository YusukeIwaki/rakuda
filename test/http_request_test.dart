import 'package:test/test.dart';

import '../lib/src/http.dart';

void main() {
  test('Request#setHeader', () {
    final request = Request('GET', '/hoge', [], [], null);
    expect(request.headers, isEmpty);
    request.setHeader('User-Agent', 'DART');
    expect(
      request.headers.firstWhere((e) => e.key == 'User-Agent').value,
      'DART',
    );
    request.setHeader('User-Agent', 'DART2');
    expect(
      request.headers.firstWhere((e) => e.key == 'User-Agent').value,
      'DART2',
    );
  });
}
