import 'package:catatan_masa_depan/models/mood.dart';

class Diary {
  final int? id;
  final String title;
  final String content;
  final DateTime date;
  final List<Mood> moods;

  Diary({
    this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.moods,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }
}
