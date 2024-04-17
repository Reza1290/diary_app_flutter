class DetailDiary {
  final int diaryId;
  final int moodId;

  DetailDiary({
    required this.diaryId,
    required this.moodId,
  });

  Map<String, dynamic> toMap() {
    return {
      'diaryId': diaryId,
      'moodId': moodId,
    };
  }
}
