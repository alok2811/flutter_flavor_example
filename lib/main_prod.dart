import 'package:flutter/cupertino.dart';
import 'package:flutter_flavor_example/common_main.dart';
import 'package:flutter_flavor_example/flavor_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.setEnvironment(Environment.prod);
  commonMain();
}
