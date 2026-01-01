import 'dart:math';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:audio_streamer/audio_streamer.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioStreamingApp extends StatefulWidget {
  const AudioStreamingApp({super.key});

  @override
  AudioStreamingAppState createState() => AudioStreamingAppState();
}

class AudioStreamingAppState extends State<AudioStreamingApp> {
  int? sampleRate;
  bool isRecording = false;
  List<double> audio = [];
  List<double>? latestBuffer;
  double? recordingTime;
  StreamSubscription<List<double>>? audioSubscription;

  /// Check if microphone permission is granted.
  Future<bool> checkPermission() async => await Permission.microphone.isGranted;

  /// Request the microphone permission.
  Future<void> requestPermission() async =>
      await Permission.microphone.request();

  /// Call-back on audio sample.
  void onAudio(List<double> buffer) async {
    audio.addAll(buffer);

    AudioStreamer().sampleRate = 16000;

    // Get the actual sampling rate, if not already known.
    sampleRate ??= await AudioStreamer().actualSampleRate;
    print(sampleRate);
    recordingTime = audio.length / sampleRate!;

    if (buffer.reduce(max) > 0.4) {
      print("[LOG] User melakukan input!");
    }

    setState(() => latestBuffer = buffer);
  }

  /// Call-back on error.
  void handleError(Object error) {
    setState(() => isRecording = false);
    print(error);
  }

  /// Start audio sampling.
  void start() async {
    // Check permission to use the microphone.
    //
    // Remember to update the AndroidManifest file (Android) and the
    // Info.plist and pod files (iOS).
    if (!(await checkPermission())) {
      await requestPermission();
    }

    // Set the sampling rate - works only on Android.
    AudioStreamer().sampleRate = 22100;

    // Start listening to the audio stream.
    audioSubscription = AudioStreamer().audioStream.listen(
      onAudio,
      onError: handleError,
    );

    setState(() => isRecording = true);
  }

  /// Stop audio sampling.
  void stop() async {
    audioSubscription?.cancel();
    setState(() => isRecording = false);
  }

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(25),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    isRecording ? "Mic: ON" : "Mic: OFF",
                    style: TextStyle(
                      fontSize: 25,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
                Text(''),
                Text('Max amp: ${latestBuffer?.reduce(max)}'),
                Text('Min amp: ${latestBuffer?.reduce(min)}'),
                Text('${recordingTime?.toStringAsFixed(2)} seconds recorded.'),
                CupertinoButton.filled(
                  onPressed: isRecording ? stop : start,
                  child: isRecording
                      ? Icon(CupertinoIcons.stop_circle_fill)
                      : Icon(CupertinoIcons.mic_circle_fill),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
