import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const demo = 'http://35.247.153.68/demo/';

class UploadScreen extends StatefulWidget {
  final File video;

  const UploadScreen({this.video});

  @override
  _UploadScreenState createState() => _UploadScreenState(video: video);
}

class Autoedit {
  File video;
  var command;
  http.Response response;

  Future<void> getDemo() async {
    response = await http.get(demo);
    if (response.statusCode == 200) {
      command = response.body;
    } else {
      print(response.statusCode);
    }
  }
}

class _UploadScreenState extends State<UploadScreen> {
  File video;
  Autoedit _autoEdit;
  String _msg = 'none';
  bool _isRequesting = false;

  _UploadScreenState({this.video});

  void logLongString(String s) {
    if (s == null || s.length <= 0) return;
    const int n = 1000;
    int startIndex = 0;
    int endIndex = n;
    while (startIndex < s.length) {
      if (endIndex > s.length) endIndex = s.length;
      print(s.substring(startIndex, endIndex));
      startIndex += n;
      endIndex = startIndex + n;
    }
  }

  getDemoBtn() async {
    setState(() {
      _isRequesting = true;
      _msg = 'Requesting';
    });
    Autoedit autoEdit = Autoedit();
    await autoEdit.getDemo();
    setState(() {
      print('=================================');
      print('Set State');
      print('Status code: ${autoEdit.response.statusCode}');
      logLongString(autoEdit.command);
//      print('Body: ${autoEdit.command}');
      _autoEdit = autoEdit;

      _isRequesting = false;
      _msg = 'finish request';
      print('=================================');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              child: Text(
                _autoEdit == null ? 'Upload place' : _autoEdit.command,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text("Status: ${_msg}"),
          ),
          RaisedButton(
            child: Text('Get Demo Command'),
            onPressed: () {
              getDemoBtn();
            },
          ),
          RaisedButton(
            child: Text('Reset'),
            onPressed: () {
              setState(() {
                _autoEdit.command = "";
                _isRequesting = false;
                _msg = 'none';
              });
            },
          ),
        ],
      ),
    );
  }
}
