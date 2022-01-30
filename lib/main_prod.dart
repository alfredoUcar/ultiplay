import 'package:flutter/material.dart';
import 'package:ultiplay/app.dart';

void main() async {
  await App.init();
  runApp(App.create('prod'));
}
