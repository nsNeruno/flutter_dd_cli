import 'package:flutter_dd_cli/flutter_dd_cli.dart';

void main(List<String> arguments,) async {
  final cli = FlutterDDCLI(arguments,);
  await cli.run();
}