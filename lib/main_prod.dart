import 'package:flutter/material.dart';
import 'configs/app_config.dart';
import 'app.dart';

void main() {
  AppConfig.setEnvironment(Environment.prod);
  runApp(const MyApp());
}
