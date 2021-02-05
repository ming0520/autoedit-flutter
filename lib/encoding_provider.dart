import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

removeExtension(String path) {
  final str = path.substring(0, path.length - 4);
  return str;
}

class EncodingProvider {
  static final FlutterFFmpeg _encoder = FlutterFFmpeg();
  static final FlutterFFprobe _probe = FlutterFFprobe();
  static final FlutterFFmpegConfig _config = FlutterFFmpegConfig();

  static Future<void> process(arguments) async {
    final int rc = await _encoder.execute(arguments);
    assert(rc == 0);
  }

  static void enableStatisticsCallback(Function cb) {
    return _config.enableStatisticsCallback(cb);
  }

  static Future<void> cancel() async {
    await _encoder.cancel();
  }
}
