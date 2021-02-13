//import 'dart:io';
//
//import 'package:chewie/chewie.dart';
//import 'package:flutter/material.dart';
//import 'package:video_player/video_player.dart';
//
//class VideoScreen extends StatefulWidget {
//  static String id = 'video_screen';
//  final File video;
//  VideoScreen({@required this.video});
//  @override
//  _VideoScreenState createState() => _VideoScreenState();
//}
//
//class _VideoScreenState extends State<VideoScreen> {
//  VideoPlayerController videoPlayerController;
//  ChewieController chewieController;
//  Chewie chewie;
//
//  void initState() {
//    super.initState();
//    print('Video Screen Load ${widget.video.path}');
//    loadVideo(widget.video);
//  }
//
//  Future<void> loadVideo(File video) async {
//    videoPlayerController = VideoPlayerController.file(video);
//
//    await videoPlayerController.initialize();
//
//    chewieController = ChewieController(
//      videoPlayerController: videoPlayerController,
//      autoPlay: true,
//      looping: true,
//    );
//    chewie = Chewie(controller: chewieController);
//
////    final playerWidget = Chewie(
////      controller: chewieController,
////    );
//  }
//
////  @override
////  void dispose() {
////    chewieController.videoPlayerController.dispose();
////    chewieController.dispose();
////    super.dispose();
////  }
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:video_player/video_player.dart';

import 'constant.dart';
import 'upload_screen.dart';

class VideoScreen extends StatefulWidget {
  final File video;

  @override
  VideoScreen({@required this.video});
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  File video;
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  Chewie chewie;
  bool _newVideo = false;

  void initState() {
    this.video = widget.video;
    _loadVideo(this.video);
    super.initState();
  }

  _loadVideo(File video) async {
//    videoPlayerController = VideoPlayerController.file(_video);
    videoPlayerController = VideoPlayerController.file(video);
    await videoPlayerController.initialize();

    chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: false,
        looping: false,
        autoInitialize: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        });

    setState(() {
      chewie = Chewie(controller: chewieController);
    });
  }

  @override
  void dispose() {
    chewieController.videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  _uploadScreen() async {
    File newVideo =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return UploadScreen(
        video: File(widget.video.path),
      );
    }));
    setState(() {
      if (newVideo.path != video.path) {
        _newVideo = true;
      }
      _loadVideo(newVideo);
    });
  }

  Widget _displayLoading() {
    if (widget.video == null) {
      return Center(
        child: Text('No video selected !'),
      );
    }
//    final spinkit = SpinKitRing(
//      color: Colors.blue,
//    );

//    final spinkit = SpinKitFadingCircle(
//      itemBuilder: (BuildContext context, int index) {
//        return DecoratedBox(
//          decoration: BoxDecoration(
//            color: index.isEven ? Colors.red : Colors.green,
//          ),
//        );
//      },
//    );
    Container container = Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SPINKIT,
          SizedBox(
            height: 30.0,
          ),
          Text('Loading video ... '),
        ],
      ),
    );
    return container;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: chewie == null ? _displayLoading() : chewie,
//            child: _displayLoading(),
          ),
          RaisedButton(
              child: Text('Ok'),
              onPressed: () {
                _uploadScreen();
              }),
        ],
      ),
    );
  }
}
