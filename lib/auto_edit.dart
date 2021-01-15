import 'dart:io';

import 'package:autoedit/network_helper.dart';

class Autoedit {
  File video;
  var command;

  Future<void> getDemo() async {
    NetworkHelper networkHelper = NetworkHelper('http://35.247.153.68/demo/');
    command = networkHelper.getData();
  }
}
