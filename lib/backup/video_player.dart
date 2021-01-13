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
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      body: Column(
//        children: [
//          Expanded(
//            child: Center(child: chewie == null ? Text('No video') : chewie),
//          ),
//        ],
//      ),
//    );
//  }
//}
