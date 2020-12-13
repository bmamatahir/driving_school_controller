import 'dart:async';
import 'dart:io';

import 'package:driving_school_controller/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

// keep tracking: recording status & duration
class AudioRecorderBloc extends ChangeNotifier {
  Timer _timer;
  FlutterAudioRecorder _recorder;
  Recording _recording;
  RecordingStatus _recordingStatus = RecordingStatus.Unset;

  StreamController<Duration> _duration = StreamController.broadcast();

  AudioRecorderBloc();

  Stream<Duration> get duration => _duration.stream;

  RecordingStatus get recordingStatus => _recordingStatus;

  set recordingStatus(RecordingStatus value) {
    _recordingStatus = value;
    notifyListeners();
  }

  Future<Recording> stop() async {
    if (recordingStatus != RecordingStatus.Recording)
      throw 'status should be recording, but we found ${recordingStatus.toString()}';
    var recording = await _recorder?.stop();
    recordingStatus = RecordingStatus.Stopped;
    _timer.cancel();
    _timer = null;

    return recording;
  }

  Future start() async {
    bool hasPermission = await FlutterAudioRecorder.hasPermissions;
    if (!hasPermission) throw 'App not allowed to use microphone.';

    final String dir = await Util.createFolderInAppDocDir("audios");

    String key = Util.getRandomString(25);

    String path = "$dir$key.wav";

    final audio = File(path);

    this._recorder = FlutterAudioRecorder(path);

    await this._recorder.initialized;

    recordingStatus = RecordingStatus.Initialized;

    notifyListeners();

    await _recorder.start();
    _recording = await _recorder.current(channel: 0);

    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      _duration.sink.add(Duration(seconds: t.tick));
    });

    recordingStatus = RecordingStatus.Recording;
  }
}
