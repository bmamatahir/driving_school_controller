import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note {
  @HiveField(0)
  final String category;

  @HiveField(1)
  final String comment;

  @HiveField(2)
  final String record_path;

  @HiveField(3)
  final String photo_path;

  @HiveField(4)
  final DateTime created_at;

  @HiveField(5)
  final int favorite;

  @HiveField(6)
  final List<int> wrongAnswer;

  Note({this.category, this.comment, this.record_path, this.photo_path,
      this.created_at, this.favorite, this.wrongAnswer});

  @override
  String toString() {
    return "Note { category: $category, comment: $comment, record_path: $record_path, photo_path: $photo_path, created_at: $created_at, favorite: $favorite, wrongAnswer: $wrongAnswer}";
  }
}
