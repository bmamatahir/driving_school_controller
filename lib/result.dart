import 'package:driving_school_controller/audio_recorder_bloc.dart';
import 'package:driving_school_controller/data.dart';
import 'package:driving_school_controller/main.dart';
import 'package:driving_school_controller/qa_model.dart';
import 'package:driving_school_controller/take_note_bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './enums.dart';
import 'question_answers_bloc.dart';

class Result extends StatefulWidget {
  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<Result> {
  QuestionAnswersBloc avm;

  @override
  void initState() {
    super.initState();
    avm = Provider.of<QuestionAnswersBloc>(context, listen: false);
  }

  List<int> wrongAnswers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => MyHomePage()),
              (Route<dynamic> route) => false);
          avm.reset();
        },
        tooltip: 'Restart',
        child: Icon(Icons.refresh),
      ),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 5,
          children: List.generate(
            avm.drivingLicenceType.questionNumbers,
            (index) {
              return SizedBox(
                height: MediaQuery.of(context).size.height /
                    (avm.drivingLicenceType.questionNumbers / 5).floor(),
                child: MaterialButton(
                  padding: EdgeInsets.all(0),
                  color: emptyQuestion(index + 1)
                      ? Colors.white10
                      : isWrong(index + 1) ? Colors.red : Colors.black12,
                  child: Stack(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${index + 1}',
                            style: Theme.of(context).textTheme.body2,
                          ),
                          const Divider(
                            color: Colors.black12,
                            thickness: 1,
                          ),
                          getAnswers(index + 1),
                        ],
                      ),
                      if (_confirmedAnswers(index + 1))
                        Positioned(
                          top: 2,
                          right: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.yellowAccent.withOpacity(.3),
                            ),
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              '?',
                              style: Theme.of(context).textTheme.body2.copyWith(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onPressed: () => markAnswerAsWrong(index + 1),
                  onLongPress: () => _makeNote(index + 1),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Text getAnswers(qId) {
    QuestionAnswers qa = avm.getQA(qId);

    if (qa == null || qa.isEmpty()) return Text("---");

    return Text(
      qa.printAnswers(),
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
    );
  }

  bool emptyQuestion(qId) {
    QuestionAnswers qa = avm.getQA(qId);
    if (qa == null) return false;
    return avm.getQA(qId).isEmpty();
  }

  bool isWrong(qId) {
    return wrongAnswers.contains(qId);
  }

  markAnswerAsWrong(qId) {
    if (wrongAnswers.contains(qId)) {
      setState(() {
        wrongAnswers.remove(qId);
      });
    } else
      setState(() {
        wrongAnswers.add(qId);
      });
  }

  bool _confirmedAnswers(qId) {
    bool r = avm.confirmedAnswer(qId);
    return r;
  }

  _makeNote(int questionId) {
    var audioRecorderBloc = AudioRecorderBloc();
    var takeNoteBloc = TakeNoteBloc(
        audioRecorderBloc: audioRecorderBloc,
        firstAnswer: avm.getQA(questionId)?.answers ?? []);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiProvider(providers: [
          ChangeNotifierProvider.value(value: audioRecorderBloc),
          ChangeNotifierProvider.value(value: takeNoteBloc),
        ], child: TakeNote());
      },
    );
  }
}

class TakeNote extends StatefulWidget {
  const TakeNote({
    Key key,
  }) : super(key: key);

  @override
  _TakeNoteState createState() => _TakeNoteState();
}

class _TakeNoteState extends State<TakeNote> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text("Take Note"),
      content: Column(
        children: <Widget>[
          DropdownButton<String>(
            isExpanded: true,
            value: CATEGORIES[0],
            items: CATEGORIES
                .map((c) => DropdownMenuItem(
                      child: Text(c),
                      value: c,
                    ))
                .toList(),
            onChanged: (String cat) {},
          ),
          TextField(
            maxLines: 2,
            decoration: InputDecoration(hintText: "Enter your text here"),
          ),
          VoiceComment()
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: new Text(
            "Exit",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: new Text("Save"),
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    tn = Provider.of<TakeNoteBloc>(context, listen: false);
    ar = Provider.of<AudioRecorderBloc>(context, listen: false);
  }

  TakeNoteBloc tn;
  AudioRecorderBloc ar;

  startRecording() {}

  stopRecording() {}

  cancelRecording() {}
}

class VoiceComment extends StatelessWidget {
  const VoiceComment({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.mic,
            color: Theme.of(context).primaryColor,
          ),
        ),
        Spacer(),
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.close,
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}
