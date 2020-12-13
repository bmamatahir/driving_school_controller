import 'package:driving_school_controller/hive/type_adapters/note.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

const String hquestionsBoxName = "questions";
const String hpreferencesBoxName = "preferences";
const String hnotes = "notes";

const String hdrivingLicenceType = "driving_licence_type";
const String hquestionAutoNextDuration = "question_auto_next_duration";

class HiveDB {
  Future<void> connect() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    Hive.registerAdapter(NoteAdapter());

    await Future.wait([
      Hive.openBox<Note>(hnotes,
          compactionStrategy: (entries, deletedEntries) => deletedEntries > 3),
      Hive.openBox(hpreferencesBoxName),
    ]);
  }

  Box getPreferencesBox() {
    return Hive.box(hpreferencesBoxName);
  }

  Future close() {
    return Hive.close();
  }

  Box<Note> getNotesBox() {
    return Hive.box<Note>(hnotes);
  }
}
