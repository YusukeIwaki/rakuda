import 'package:rakuda/rakuda.dart';

void main(List<String> args) async {
  await createJSONClient(args, baseURL: 'https://api.github.com');
}
