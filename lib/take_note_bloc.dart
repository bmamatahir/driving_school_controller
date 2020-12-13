import 'dart:async';

import 'package:driving_school_controller/audio_recorder_bloc.dart';
import 'package:driving_school_controller/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';

class TakeNoteBloc extends ChangeNotifier {
  String category;
  String comment;
  String record_path;
  String photo_path;
  DateTime created_at;
  int favorite;
  final List<int> firstAnswer;

  final AudioRecorderBloc audioRecorderBloc;

  TakeNoteBloc({this.firstAnswer, this.audioRecorderBloc});
}
