import 'package:driving_school_controller/question_answers_bloc.dart';
import 'package:driving_school_controller/response_area.dart';
import 'package:driving_school_controller/take_note_bloc.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:provider/provider.dart';

import 'hive/hivedb.dart';
import './enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HiveDB hiveDB = HiveDB();
  await hiveDB.connect();

  DrivingLicenceType drivingLicenceType = EnumToString.fromString(
      DrivingLicenceType.values,
      hiveDB.getPreferencesBox().get(hdrivingLicenceType) ?? "B");

  int autoNextDuration =
      hiveDB.getPreferencesBox().get(hquestionAutoNextDuration) ?? 15;

  LIST_OF_LANGS = ['ar', 'en', 'fr'];
  LANGS_DIR = 'assets/i18n/';

  await translator.init();

  runApp(
    MultiProvider(
      providers: [
        Provider<HiveDB>.value(value: hiveDB),
        ChangeNotifierProvider<QuestionAnswersBloc>.value(
            value: QuestionAnswersBloc(
                drivingLicenceType: drivingLicenceType,
                autoNextSec: autoNextDuration)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Driving Training',
      theme: ThemeData(),
      home: MyHomePage(),
      localizationsDelegates: translator.delegates,
      locale: translator.locale,
      supportedLocales: translator.locals(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  HiveDB _hiveDB;
  int defaultNQuestions = 40;

  TextEditingController andc = TextEditingController();
  QuestionAnswersBloc avm;

  Map<DrivingLicenceType, String> _drivingLicenceTypes = {
    DrivingLicenceType.J: 'J',
    DrivingLicenceType.A: 'A',
    DrivingLicenceType.B: 'B',
    DrivingLicenceType.C: 'C',
    DrivingLicenceType.D: 'D',
    DrivingLicenceType.EB: 'EB',
    DrivingLicenceType.EC: 'EC',
    DrivingLicenceType.ED: 'ED',
  };

  DrivingLicenceType _selectedDrivingLicenceType;
  String _lang;

  @override
  void dispose() {
    super.dispose();
    andc.dispose();
  }

  @override
  void initState() {
    super.initState();

    _hiveDB = Provider.of<HiveDB>(context, listen: false);
    avm = Provider.of<QuestionAnswersBloc>(context, listen: false);

    _selectedDrivingLicenceType = EnumToString.fromString(
        DrivingLicenceType.values,
        _hiveDB.getPreferencesBox().get(hdrivingLicenceType) ?? "B");

    andc.text = avm.autoNextSec.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translator.translate("appTitle")),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                translator.translate("select_language"),
                style: Theme.of(context).textTheme.caption.copyWith(height: 2),
              ),
              DropdownButton<String>(
                value: _lang ?? translator.currentLanguage,
                items: LIST_OF_LANGS
                    .map((v) => DropdownMenuItem(
                          child: Text(v),
                          value: v,
                        ))
                    .toList(),
                onChanged: (String lang) {
                  setState(() {
                    _lang = lang;
                    translator.setNewLanguage(context,
                        newLanguage: lang, remember: true, restart: true);
                  });
                },
              ),
              Text(
                translator.translate("driver_license_type"),
                style: Theme.of(context).textTheme.caption.copyWith(height: 2),
              ),
              DropdownButton<DrivingLicenceType>(
                value: _selectedDrivingLicenceType,
                items: _drivingLicenceTypes.keys
                    .map((k) => DropdownMenuItem(
                          child: Text(_drivingLicenceTypes[k]),
                          value: k,
                        ))
                    .toList(),
                onChanged: (DrivingLicenceType dlt) {
                  setState(() {
                    _selectedDrivingLicenceType = dlt;
                    avm.drivingLicenceType = dlt;

                    _hiveDB
                        .getPreferencesBox()
                        .put(hdrivingLicenceType, EnumToString.parse(dlt));
                  });
                },
              ),
              SizedBox(
                child: TextField(
                  controller: andc,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: translator.translate("auto_next_duration"),
                  ),
                  onChanged: (String v) {
                    if (v.isNotEmpty) {
                      _hiveDB
                          .getPreferencesBox()
                          .put(hquestionAutoNextDuration, int.tryParse(v));
                      avm.autoNextSec = int.tryParse(v);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => ResponseArea())),
        tooltip: 'Start Training',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
