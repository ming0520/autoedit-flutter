import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class CameraScreen extends StatefulWidget {
  static String id = 'camera_screen';
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File _video;
  String msg;
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;
  Chewie chewie;

  _record({bool isRecord}) async {
    ImageSource imgSrc;
    if (isRecord) {
      imgSrc = ImageSource.camera;
    } else {
      imgSrc = ImageSource.gallery;
    }

    var video = await ImagePicker.pickVideo(source: imgSrc);
    print(video.path);
    if (video != null && video.path != null) {
      print(video.path);
      setState(() {
        _video = File(video.path);
        msg = _video.path;
      });
      videoPlayerController = VideoPlayerController.file(_video);

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

//      chewieController = ChewieController(
//        videoPlayerController: videoPlayerController,
//        autoPlay: true,
//        looping: true,
//      );

//      final playerWidget = Chewie(
//        controller: chewieController,
//      );

      setState(() {
        chewie = Chewie(controller: chewieController);
      });

//      GallerySaver.saveVideo(_video.path, albumName: 'AutoEdit')
//          .then((bool success) {
//        setState(() {
//          msg = '${_video.path} saved!';
//        });
//      });
    }
  }

  @override
  void dispose() {
    chewieController.videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auto Edit'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: chewie == null ? Text('No video') : chewie,
          ),
          RaisedButton(
            child: Center(
              child: Text('Import'),
            ),
            onPressed: () {
              print('Import pressed!');
              _record(isRecord: false);
            },
          ),
          RaisedButton(
            child: Center(
              child: Text('Record'),
            ),
            onPressed: () {
              print('Record pressed!');
              _record(isRecord: true);
            },
          ),
        ],
      ),
    );
  }
}
