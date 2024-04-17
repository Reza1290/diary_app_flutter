import 'package:catatan_masa_depan/models/detail_dairy.dart';
import 'package:catatan_masa_depan/models/diary.dart';
import 'package:catatan_masa_depan/models/mood.dart';
import 'package:catatan_masa_depan/utils/date_formatter.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DiaryDatabase {
  static final DiaryDatabase instance = DiaryDatabase._init();
  final String _diaryTable = 'diaries';
  final String _moodTable = 'moods';
  final String _detailDiaryTable = 'detail_diary';

  DiaryDatabase._init();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('diary_database.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreateDB);
  }

  Future<void> _onCreateDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_diaryTable (
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT,
        date TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $_moodTable (
        id INTEGER PRIMARY KEY,
        name TEXT,
        path TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $_detailDiaryTable (
        id INTEGER PRIMARY KEY,
        diaryId INTEGER,
        moodId INTEGER,
        FOREIGN KEY(diaryId) REFERENCES $_diaryTable(id) ON DELETE CASCADE,
        FOREIGN KEY(moodId) REFERENCES $_moodTable(id) ON DELETE CASCADE
      )
    ''');
    final Map<String, String> moodPathToName = {
      "emoji_grin": "Happy",
      "emoji": "Normal",
      "emoji_angry": "Angry",
      "emoji_sad": "Sad",
      "emoji_sleeping": "Sleepy"
    };

    for (var entry in moodPathToName.entries) {
      await db.insert(_moodTable, {'name': entry.value});
    }
  }

  Future<void> insertDiary(Diary diary, {int? updateId}) async {
    final db = await database;
    int id;

    if (updateId != null) {
      await db.update(
        _diaryTable,
        {
          'title': diary.title,
          'content': diary.content,
          'date': diary.date.toString(), // Convert DateTime to string
        },
        where: 'id = ?',
        whereArgs: [updateId],
      );
      id = updateId;
      await db.delete(_detailDiaryTable, where: "diaryId = ?", whereArgs: [id]);
    } else {
      id = await db.insert(
        _diaryTable,
        diary.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    for (var mood in diary.moods) {
      await db.insert(
        _detailDiaryTable,
        DetailDiary(diaryId: id, moodId: mood.id ?? 1).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Diary>> getDiaries() async {
    final db = await database;
    final List<Map<String, dynamic>> diaryMaps = await db.query(_diaryTable);
    final List<Map<String, dynamic>> detailMaps =
        await db.query(_detailDiaryTable);

    final List<Diary> diaries = [];
    for (var diaryMap in diaryMaps) {
      final List<Mood> moods = [];
      for (var detailMap in detailMaps) {
        if (detailMap['diaryId'] == diaryMap['id']) {
          final moodId = detailMap['moodId'];
          final moodMap =
              await db.query(_moodTable, where: 'id = ?', whereArgs: [moodId]);
          final moodName = moodMap[0]['name'] as String;
          moods.add(Mood(id: moodId, name: moodName));
        }
      }

      diaries.add(Diary(
        id: diaryMap['id'],
        title: diaryMap['title'],
        content: diaryMap['content'],
        date: DateTime.parse(diaryMap['date']),
        moods: moods,
      ));
    }
    return diaries;
  }

  Future<List<Diary>> getDiariesByDate(DateTime selectedDate,
      {int limit = 0}) async {
    final db = await database;

    // Extract the date part only
    final formattedDate = selectedDate.toString().substring(0, 10);

    try {
      final List<Map<String, dynamic>> diaryMaps = limit > 0
          ? await db.query(
              _diaryTable,
              where: 'date LIKE ?',
              whereArgs: [
                '$formattedDate%'
              ], // Match the formatted date followed by any time
              limit: limit > 0 ? limit : null,
            )
          : await db.query(
              _diaryTable,
            );

      final List<Map<String, dynamic>> detailMaps =
          await db.query(_detailDiaryTable);

      final List<Diary> diaries = [];
      for (var diaryMap in diaryMaps) {
        final List<Mood> moods = [];
        for (var detailMap in detailMaps) {
          if (detailMap['diaryId'] == diaryMap['id']) {
            final moodId = detailMap['moodId'];
            final moodMap = await db
                .query(_moodTable, where: 'id = ?', whereArgs: [moodId]);
            final moodName = moodMap[0]['name'] as String;
            moods.add(Mood(id: moodId, name: moodName));
          }
        }

        final DateTime diaryDate = DateTime.parse(diaryMap['date']);
        diaries.add(Diary(
          id: diaryMap['id'],
          title: diaryMap['title'],
          content: diaryMap['content'],
          date: diaryDate,
          moods: moods,
        ));
      }
      print(detailMaps);
      return diaries;
    } catch (e) {
      print('Error fetching diaries by date: $e');
      return [];
    }
  }

  Future<Map<String, List<Diary>>> getMemories() async {
    final db = await database;
    final Map<String, List<Diary>> groupedDiaries = {};

    final List<Map<String, dynamic>> diaryMaps = await db.query(_diaryTable);
    final List<Map<String, dynamic>> detailMaps =
        await db.query(_detailDiaryTable);

    for (var diaryMap in diaryMaps) {
      final List<Mood> moods = [];
      for (var detailMap in detailMaps) {
        if (detailMap['diaryId'] == diaryMap['id']) {
          final moodId = detailMap['moodId'];
          final moodMap =
              await db.query(_moodTable, where: 'id = ?', whereArgs: [moodId]);
          final moodName = moodMap[0]['name'] as String;
          moods.add(Mood(id: moodId, name: moodName));
        }
      }

      final DateTime diaryDate = DateTime.parse(diaryMap['date']);
      final String formattedDate = HumanReadableDateFormatter.dateNowFormatter(
          diaryDate); // Format date without time
      final dairy = Diary(
        id: diaryMap['id'],
        title: diaryMap['title'],
        content: diaryMap['content'],
        date: diaryDate,
        moods: moods,
      );

      groupedDiaries.putIfAbsent(formattedDate, () => []).add(dairy);
    }

    return groupedDiaries;
  }

  Future<Diary?> getDiaryById(int id) async {
    final db = await database;

    try {
      final List<Map<String, dynamic>> diaryMaps = await db.query(
        _diaryTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (diaryMaps.isEmpty) {
        return null;
      }

      final diaryMap = diaryMaps.first;
      final DateTime diaryDate = DateTime.parse(diaryMap['date']);

      final List<Map<String, dynamic>> detailMaps = await db.query(
        _detailDiaryTable,
        where: 'diaryId = ?',
        whereArgs: [id],
      );

      final List<Mood> moods = [];
      for (var detailMap in detailMaps) {
        final moodId = detailMap['moodId'];
        final moodMap = await db.query(
          _moodTable,
          where: 'id = ?',
          whereArgs: [moodId],
        );
        final moodName = moodMap[0]['name'] as String;
        moods.add(Mood(id: moodId, name: moodName));
      }

      return Diary(
        id: diaryMap['id'],
        title: diaryMap['title'],
        content: diaryMap['content'],
        date: diaryDate,
        moods: moods,
      );
    } catch (e) {
      print('Error fetching diary by ID: $e');
      return null;
    }
  }

  Future<void> insertMood(Mood mood) async {
    final db = await database;
    await db.insert(
      _moodTable,
      mood.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Mood>> getMoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_moodTable);
    return List.generate(maps.length, (i) {
      return Mood(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> deleteDiary(int id) async {
    final db = await database;
    int diaryId = await db.delete(
      _diaryTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    await db.delete(_detailDiaryTable, where: 'id = ?', whereArgs: [diaryId]);
  }
}
