import 'dart:io';
import 'package:pubguard/pubguard.dart';

void main(List<String> arguments) async {
  exit(await Commands.run(arguments));
}