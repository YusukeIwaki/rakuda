import 'package:rakuda/rakuda.dart';

void main(List<String> arguments) async {
  await createJSONClient(
    arguments,
    baseURL: 'https://petstore.swagger.io/v2',
  );
}
