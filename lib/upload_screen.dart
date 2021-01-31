//import 'dart:html';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
//import 'package:flutter_uploader/flutter_uploader.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
  var arguments;
  http.Response response;

  Directory extDir;
  String outAudioDirPath;
  String outVideoDirPath;
  String fileNameOnly;

  var duration;
  var fps;

  static final FlutterFFmpeg _ffmpeg = FlutterFFmpeg(); // encoder
  static final FlutterFFprobe _ffprobe = FlutterFFprobe(); //probe
  static final FlutterFFmpegConfig _ffmpegConfig =
      FlutterFFmpegConfig(); //config

  Autoedit({@required this.video});

  Future<void> getDir() async {
    this.extDir = await getExternalStorageDirectory();
    this.fileNameOnly = path.basenameWithoutExtension(video.path);
    this.outAudioDirPath = '${this.extDir.path}/${this.fileNameOnly}.wav';
    this.outVideoDirPath =
        '${this.extDir.path}/${this.fileNameOnly}_EDITED.mp4';
    MediaInformation mediaInfo = await _ffprobe.getMediaInformation(video.path);
    Map<dynamic, dynamic> mp = mediaInfo.getAllProperties();

    print('=======================getDir====================');
    this.duration = double.parse(mp['streams'][0]['duration']);
    var totalFrames = double.parse(mp['streams'][0]['nb_frames']);
    this.fps = totalFrames / this.duration;
    print('=================================================');
  }

  String getArguments() {
    this.arguments =
        '-y -i ' + video.path + ' ' + command + " " + outVideoDirPath;
    return this.arguments;
  }

  Future<void> getDemo() async {
    response = await http.get(demo);
    if (response.statusCode == 200) {
      command = response.body;
    } else {
      print(response.statusCode);
    }
  }

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

  Future<void> convertToWav() async {
    final arguments = '-y -i ' +
        video.path +
        ' -c:a pcm_s16le' +
        ' -b:a 8000 -ac 1 -ar 8000 -vn ' +
        outAudioDirPath;

//    final arguments = '-y -i ' +
//        video.path +
//        '-acodec libmp3lame' +
//        ' -b:a 16k -ac 1 -ar 16000 -vn ' +
//        outAudioDirPath;
    print('=======================Arguments====================');
    print(arguments);
    final int rc = await _ffmpeg.execute(arguments.toString());
    assert(rc == 0);
    print('outputDir: $outAudioDirPath');
    print('====================================================');
  }

  Future<void> renderVideo() async {
    final arguments =
        '-y -i ' + video.path + ' ' + command + " " + outVideoDirPath;
//    this.arguments =
//        '-y -i ' + video.path + ' ' + command + " " + outVideoDirPath;
    print('=======================Arguments====================');
//    logLongString(arguments);
    print("Rendering: Start to execute arguments...");
    final int rc = await _ffmpeg.execute(arguments);
    assert(rc == 0);
    print("Rendering: Finish execute arguments...");
    print('outputDir: $outVideoDirPath');
    print('====================================================');
  }
}

class _UploadScreenState extends State<UploadScreen> {
  File video;
  Autoedit _autoEdit;
  String _msg = 'none';
  bool _isRequesting = false;
//  final uploader = FlutterUploader();

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

//  Future<void> getAPI() async {
//    setState(() {
//      _msg = 'Initializing API';
//      _isRequesting = true;
//    });
//    print('API: Initializing ...');
//    var postUri = Uri.parse('http://35.247.153.68/api/');
//    var request = new http.MultipartRequest('POST', postUri);
//    setState(() {
//      _msg = 'Adding file to API';
//    });
//    print('API: Adding file ...');
//    request.files.add(
//        await http.MultipartFile.fromPath('file', _autoEdit.outAudioDirPath));
//    print('API: Uploading ...');
//    setState(() {
//      _msg = 'Uploading file to API';
//    });
//    request
//        .send()
//        .then((result) async {
//          http.Response.fromStream(result).then((valueResponse) {
//            if (valueResponse.statusCode == 200) {
//              print('API: Uploaded!');
//              setState(() {
//                _msg = 'Uploaded file to API';
//              });
//              _autoEdit.response = valueResponse;
//              _autoEdit.command = valueResponse.body;
//              print('API: ${_autoEdit.command}');
//            }
//          });
//        })
//        .catchError((err) => print('callApi: error : ' + err.toString()))
//        .whenComplete(() {});
//    setState(() {
//      _isRequesting = false;
//    });
//  }
//

//  not working perfectly

  Future<dynamic> getAPI() async {
    print(
        '===============================Requesting API =============================');
    print('API: Initializing ...');
    var postUri = Uri.parse('http://35.247.153.68/api/');
    var request = new http.MultipartRequest('POST', postUri);
    print('API: Adding file ...');
    setState(() {
      _msg = 'Adding file...';
    });
    request.files.add(await http.MultipartFile.fromPath(
        'file', _autoEdit.outAudioDirPath,
        contentType: new MediaType('media', 'wav')));
    setState(() {
      _msg = 'Uploading...';
    });
    print('API: Uploading ...');

    await request.send().then((response) {
      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          _autoEdit.command = value.toString();
        });
      }
    });
//    var response = await request.send();
//    setState(() {
//      _msg = 'Uploded';
//    });
//    print('API: Status ${response.statusCode}');
//    response.stream.transform(utf8.decoder).listen((value) {
////      logLongString(value.toString());
//      _autoEdit.command = value.toString();
//      return value.toString();
//    });

    print(
        '===============================Requested API =============================');
  }

//  Future<void> getAPI() async {
//    Dio dio = new Dio();
//    dio.options.baseUrl = 'http://35.247.153.68/api/';
//    FormData frm
//
//  }

//  Future<void> getAPI() async {
//    Dio dio = new Dio();
//    String filename = _autoEdit.video.path.split('/').last;
//    FormData formData = FormData.fromMap({
//      'file': await MultipartFile.fromFile(_autoEdit.outAudioDirPath,
//          filename: filename),
//    });
//    try {
//      var response =
//          await dio.post('http://35.247.153.68/api/', data: formData);
//      print('===================data to string===========================');
//      logLongString(response.data);
//      print('==================end data to string========================');
//    } catch (e) {
//      print(e);
//    }
//  }

  Future<void> getDemoBtn() async {
    setState(() {
//      _isRequesting = true;
      _msg = 'Getting directory';
    });
    _autoEdit = Autoedit(video: widget.video);
//    await _autoEdit.getDemo();
    await _autoEdit.getDir();
    setState(() {
      _msg = 'Converting to wav';
//      _autoEdit = autoEdit;
    });
    await _autoEdit.convertToWav();
    setState(() {
      print(
          '===============================Converting to wav =============================');
//      print('Set State');
//      print('Status code: ${_autoEdit.response.statusCode}');
//      logLongString(autoEdit.command);
//      print('Body: ${autoEdit.command}');
      _isRequesting = false;
      _msg = 'Converted to wav';
      print(
          '===============================Converted to wav =============================');
    });
    await getAPI();
    await renderVideo();
  }

  Future<void> renderVideo() async {
    setState(() {
      _msg = 'Rendering video';
    });
    print(
        '===============================Rendering video =============================');
    await _autoEdit.renderVideo();
    setState(() {
      _msg = 'Saved video to ${_autoEdit.outVideoDirPath}';
      print(
          '===============================Rendered video =============================');
    });
  }

  printCommand() {
    logLongString(_autoEdit.command);
  }

  printArguments() {
    logLongString(_autoEdit.getArguments());
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
                _autoEdit == null
                    ? 'Nothing'
                    : _autoEdit.command == null
                        ? 'Nothing'
                        : _autoEdit.command,
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
          SizedBox(
            height: 20,
          ),
          Center(
            child: Text("File: ${widget.video.path}"),
          ),
          SizedBox(
            height: 20,
          ),
          Column(
            children: [
              Center(
                child: Text(
                    "Duration: ${_autoEdit == null ? 0 : _autoEdit.duration}"),
              ),
              Center(
                child: Text("FPS: ${_autoEdit == null ? 0 : _autoEdit.fps}"),
              ),
              Center(
                child: Text(
                    "Output: ${_autoEdit == null ? 'No' : _autoEdit.outAudioDirPath}"),
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
                    _autoEdit = null;
                    _isRequesting = false;
                    _msg = 'none';
                  });
                },
              ),
              RaisedButton(
                child: Text('Command'),
                onPressed: () {
                  printCommand();
                },
              ),
              RaisedButton(
                child: Text('Argument'),
                onPressed: () {
                  printArguments();
                },
              ),
              RaisedButton(
                child: Text('Render'),
                onPressed: () {
                  _autoEdit.renderVideo();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
