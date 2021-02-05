//import 'dart:html';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import 'constant.dart';

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
  Directory extDir;
  String outAudioDirPath;
  String outVideoDirPath;
  String fileNameOnly;

  var duration;
  var fps;

//  static final FlutterFFmpeg _ffmpeg = FlutterFFmpeg(); // encoder
  static final FlutterFFprobe _ffprobe = FlutterFFprobe(); //probe
//  static final FlutterFFmpegConfig _ffmpegConfig =
//      FlutterFFmpegConfig(); //config

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
    String arguments = '-y -i ' +
        video.path +
//        ' -c:a pcm_s16le' +
        ' -acodec libmp3lame' +
        ' -b:a 16k -ac 1 -ar 16k -vn ' +
        outAudioDirPath;
    return arguments;
  }

  String convertToWav() {
    String arguments = '-y -i ' +
        video.path +
//        ' -c:a pcm_s16le' +
        ' -acodec libmp3lame' +
        ' -b:a 16k -ac 1 -ar 16k -vn ' +
        outAudioDirPath;
    return arguments;

////    final arguments = '-y -i ' +
////        video.path +
////        '-acodec libmp3lame' +
////        ' -b:a 16k -ac 1 -ar 16000 -vn ' +
////        outAudioDirPath;
//    print('=======================Arguments====================');
//    print(arguments);
//    final int rc = await _ffmpeg.execute(arguments.toString());
//    assert(rc == 0);
//    print('outputDir: $outAudioDirPath');
//    print('====================================================');
  }

  String renderVideo() {
    String arguments =
        '-y -i ' + video.path + ' ' + command + " " + outVideoDirPath;
    return arguments;
//    this.arguments =
//        '-y -i ' + video.path + ' ' + command + " " + outVideoDirPath;
//    print('=======================Arguments====================');
////    logLongString(arguments);
//    print("Rendering: Start to execute arguments...");
//    final int rc = await _ffmpeg.execute(arguments);
//    assert(rc == 0);
//    print("Rendering: Finish execute arguments...");
//    print('outputDir: $outVideoDirPath');
//    print('====================================================');
  }
}

class _UploadScreenState extends State<UploadScreen> {
  @override
  void setState(fn) {
    if (this.mounted) {
      super.setState(fn);
    }
  }

  void statisticsCallback(Statistics statistics) {
    var result = (statistics.time / 1000) / (_autoEdit.duration) * 100;
    setState(() {
      _progress = result;
      _time = statistics.time;
    });
    print(
        "Statistics: executionId: ${statistics.executionId}, time: ${statistics.time}, size: ${statistics.size}, bitrate: ${statistics.bitrate}, speed: ${statistics.speed}, videoFrameNumber: ${statistics.videoFrameNumber}, videoQuality: ${statistics.videoQuality}, videoFps: ${statistics.videoFps}");
  }

  @override
  void initState() {
    super.initState();
    _autoEdit = Autoedit(video: widget.video);
    setState(() {
      _msg = 'Getting directory ...';
    });
    _autoEdit.getDir();
    setState(() {
      _msg = 'Prepared directory';
    });
    _config.enableStatisticsCallback(this.statisticsCallback);
    _cancelDio = new CancelToken();
  }

  CancelToken _cancelDio = new CancelToken();
  File video;
  Autoedit _autoEdit;
  String _msg = 'none';
  double _progress = 0;
  int _time = 0;
  bool _serverProcessing = false;
//  final uploader = FlutterUploader();

  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
//  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

  Dio dio = new Dio();

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
//        .whenComplete(() async {
//          setState(() {
//            _msg = 'Rendering';
//          });
//          await _autoEdit.renderVideo();
//          setState(() {
//            _msg = 'Saved to ${_autoEdit.outVideoDirPath}';
//          });
//        });
//    setState(() {
//      _isRequesting = false;
//    });
//  }

//  not working perfectly

//  Future<dynamic> getAPI() async {
//    print(
//        '===============================Requesting API =============================');
//    print('API: Initializing ...');
//    var postUri = Uri.parse('http://35.247.153.68/api/');
//    var request = new http.MultipartRequest('POST', postUri);
//    print('API: Adding file ...');
//    setState(() {
//      _msg = 'Adding file...';
//    });
//    request.files.add(await http.MultipartFile.fromPath(
//        'file', _autoEdit.outAudioDirPath,
//        contentType: new MediaType('media', 'wav')));
//    setState(() {
//      _msg = 'Uploading...';
//    });
//    print('API: Uploading ...');
//
//    await request.send().then((response) {
//      if (response.statusCode == 200) {
//        response.stream.transform(utf8.decoder).listen((value) async {
//          _autoEdit.command = value.toString();
//        });
//      }
//    }).whenComplete(() async {
//      setState(() {
//        _msg = 'Rendering in API';
//      });
//      await _autoEdit.renderVideo();
//      setState(() {
//        _msg = 'Saved to' + _autoEdit.outVideoDirPath;
//      });
//    });
//    print(
//        '===============================Requested API =============================');
//  }

  //Dio
  Future<void> getAPI() async {
    // String filename = _autoEdit.video.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(_autoEdit.outAudioDirPath,
          filename: 'upload.wav'),
    });
    try {
      setState(() {
        _msg = 'Sending ...';
      });
      var response = await dio.post('http://35.247.153.68/api/',
          data: formData,
          cancelToken: _cancelDio, onSendProgress: (int sent, int total) {
        var result = (sent / total) * 100;
        print('Sending $sent/$total, $result');
        setState(() {
          _progress = result;
          if (_progress == 100.0) {
            _msg = 'Server processing...';
            _serverProcessing = true;
          }
        });
//      }, onReceiveProgress: (int rcv, int total) {
//        setState(() {
//          _msg = 'Downloading ...';
//          var result = (rcv / total) * 100;
//          _progress = result;
//        });
      }).catchError((e) {
        if (_cancelDio.isCancelled) {
          print('$e');
        }
      });

      print('===================data to string===========================');
      // logLongString(response.data);
      _autoEdit.command = response.data.toString();
      setState(() {
        _serverProcessing = false;
        _progress = 0.0;
        _msg = 'Rendering...';
        _time = 0;
      });
      String arguments = _autoEdit.renderVideo();
      await _encoder.execute(arguments);
      setState(() {
//        _msg = 'Saved to ${_autoEdit.outVideoDirPath}';
        _msg = 'Done ! ';
      });
      print('==================end data to string========================');
    } catch (e) {
      print(e);
    }
  }

  Future<void> getDemoBtn() async {
    setState(() {
      _msg = 'Converting to audio ... ';
    });
    String arguments = _autoEdit.convertToWav();
    await _encoder.execute(arguments);
//    await _encoder.executeAsync(arguments, (executionId, returnCode) {
//      print('Return code: $returnCode');
//    });
    setState(() {
      print(
          '===============================Converting to wav =============================');
//      print('Set State');
//      print('Status code: ${_autoEdit.response.statusCode}');
//      logLongString(autoEdit.command);
//      print('Body: ${autoEdit.command}');
      _msg = 'Converted to audio';
      print(
          '===============================Converted to wav =============================');
    });
    await getAPI();
    // await renderVideo();
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
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back),
            onPressed: () {
              _encoder.cancel();
              _cancelDio.cancel('cancelled');
              Navigator.pop(context, true);
            }),
        title: Text('Upload Screen'),
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
//          Expanded(
//            child: Center(
//              child: Container(
//                child: SingleChildScrollView(
//                  child: Column(children: [
//                    Text(
//                      _autoEdit == null
//                          ? 'Nothing'
//                          : _autoEdit.command == null
//                              ? 'Nothing'
//                              : _autoEdit.command,
//                      // overflow: TextOverflow.ellipsis,
//                      // maxLines: 5,
//                    ),
//                    SizedBox(
//                      height: 20,
//                    ),
//                    Center(
//                      child: Text("File: ${widget.video.path}"),
//                    ),
//                    SizedBox(
//                      height: 20,
//                    ),
//                  ]),
//                ),
//              ),
//            ),
//          ),
          Column(
            children: [
//              Center(
//                child: Text(
//                    "Duration: ${_autoEdit == null ? 0 : _autoEdit.duration}"),
//              ),
//              Center(
//                child: Text("FPS: ${_autoEdit == null ? 0 : _autoEdit.fps}"),
//              ),
//              Center(
//                child: Text(
//                    "Output: ${_autoEdit == null ? 'No' : _autoEdit.outAudioDirPath}"),
//              ),
//              SizedBox(
//                height: 20,
//              ),
//              Center(
//                child: Text("Status: $_msg"),
//              ),
//              Center(
//                child: Text("Progress: $_progress"),
//              ),
//              Center(
//                child: Text(_autoEdit == null
//                    ? '0'
//                    : _autoEdit.duration == null
//                        ? '0'
//                        : "Time(ms):  $_time/${_autoEdit.duration * 1000}"),
//              ),
//              CircularProgressIndicator(
//                backgroundColor: Colors.grey,
//                strokeWidth: 2,
//                value: _progress,
//              ),
              _serverProcessing
                  ? Container(
                      child: SPINKIT,
                    )
                  : new CircularPercentIndicator(
                      radius: 200.0,
                      lineWidth: 13.0,
                      percent:
                          ((_progress / 100) > 1.0 ? 1.0 : _progress / 100),
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          new Text('$_progress %'),
                          new Text(_autoEdit == null
                              ? '0 / 0'
                              : _autoEdit.duration == null
                                  ? '0 / 0 '
                                  : '$_time / ${(_autoEdit.duration * 1000)}'),
                        ],
                      ),
                      progressColor: Colors.green,
                    ),
              SizedBox(
                height: 20,
              ),
              new Text('Status: $_msg'),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                child: Text('Get Demo Command'),
                onPressed: () {
                  getDemoBtn();
                },
              ),
              RaisedButton(
                child: Text('Indicator'),
                onPressed: () {
                  setState(() {
                    _serverProcessing = !_serverProcessing;
                  });
                },
              ),
//              RaisedButton(
//                child: Text('Reset'),
//                onPressed: () {
//                  setState(() {
//                    _autoEdit = null;
//                    _msg = 'none';
//                    _progress = 0.0;
//                  });
//                },
//              ),
//              RaisedButton(
//                child: Text('Command'),
//                onPressed: () {
//                  printCommand();
//                },
//              ),
//              RaisedButton(
//                child: Text('Argument'),
//                onPressed: () {
//                  printArguments();
//                },
//              ),
              RaisedButton(
                child: Text(_cancelDio.isCancelled ? 'Reset token' : 'Cancel'),
                onPressed: () {
                  setState(() {
                    _progress = 0.0;
                    if (_cancelDio.isCancelled) {
                      _cancelDio = new CancelToken();
                    } else {
                      _cancelDio.cancel('cancelled');
                    }
                    _cancelDio = new CancelToken();
                    _encoder.cancel();
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
