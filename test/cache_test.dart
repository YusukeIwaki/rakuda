import 'package:rakuda/rakuda.dart';
import 'package:test/test.dart';

void main() {
  test('get, put, delete', () async {
    final cache = FileCache('test123', 'filename123');
    expect(await cache.get(), isNull);
    await cache.put('hogehoge');
    expect(await cache.get(), equals('hogehoge'));
    await cache.delete();
    expect(await cache.get(), isNull);
  });

  test('exclusiveness', () async {
    final cache1 = FileCache('test123', 'foo');
    final cache2 = FileCache('test123', 'bar');
    await Future.wait([cache1.put('foo'), cache2.put('bar')]);
    expect(await cache1.get(), equals('foo'));
    await cache1.delete();
    expect(await cache2.get(), equals('bar'));
  });
}
