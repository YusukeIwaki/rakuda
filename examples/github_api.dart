import 'package:rakuda/rakuda.dart';

void main(List<String> args) async {
  await createJSONClient(args, 'https://api.github.com');
}
