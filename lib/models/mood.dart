class Mood {
  final int? id;
  final String name;
  final String? path;
  Mood({
    this.id,
    required this.name,
    this.path,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'path': path};
  }
}

final Map<String, String> moodNameToPath = {
  "Happy": "emoji_grin",
  "Normal": "emoji",
  "Angry": "emoji_angry",
  "Sad": "emoji_sad",
  "Sleepy": "emoji_sleeping"
};
