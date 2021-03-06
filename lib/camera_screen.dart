import 'dart:io';

import 'package:autoedit/upload_screen.dart';
import 'package:autoedit/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  static String id = 'camera_screen';
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File _video;
  String msg;

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
      print('=================================================');
      print("File path: ${_video.path}");
      print('=================================================');

      if (isRecord) {
//        AlbumSaver.createAlbum(albumName: "AutoEdit");
        GallerySaver.saveVideo(video.path, albumName: 'AutoEdit')
            .then((bool success) {
          setState(() {
            msg = 'video saved';
          });
        });
      }

      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return VideoScreen(video: _video);
      }));

//      chewieController = ChewieController(
//        videoPlayerController: videoPlayerController,
//        autoPlay: true,
//        looping: true,
//      );

//      final playerWidget = Chewie(
//        controller: chewieController,
//      );

//      GallerySaver.saveVideo(_video.path, albumName: 'AutoEdit')
//          .then((bool success) {
//        setState(() {
//          msg = '${_video.path} saved!';
//        });
//      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Screen'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Text(msg == null ? 'No video selected!' : msg),
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
          RaisedButton(
              child: Center(
                child: Text('Video Screen'),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return VideoScreen(video: File(_video.path));
                }));
              }),
          RaisedButton(
            child: Center(
              child: Text('Upload Screen'),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return UploadScreen(
                  video: File(_video.path),
                );
              }));
            },
          )
        ],
      ),
    );
  }
}
