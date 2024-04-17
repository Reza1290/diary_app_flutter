import 'package:catatan_masa_depan/database.dart';
import 'package:catatan_masa_depan/models/diary.dart';
import 'package:catatan_masa_depan/models/mood.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailDairyScreen extends StatefulWidget {
  final int diaryId;
  const DetailDairyScreen({super.key, required this.diaryId});

  @override
  State<DetailDairyScreen> createState() => _DetailDairyScreenState();
}

class _DetailDairyScreenState extends State<DetailDairyScreen> {
  late bool isEditPage = false;
  late Diary? _diary;
  final List<bool> _selectedMoods = <bool>[false, false, false, false, false];
  final List<String> _moods = <String>[
    "emoji_grin",
    "emoji",
    "emoji_angry",
    "emoji_sad",
    "emoji_sleeping"
  ];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<Mood> getSelectedMoods(List<String> _moods, List<bool> _selectedMoods) {
    List<Mood> selectedMoods = [];
    for (int i = 0; i < _moods.length; i++) {
      if (_selectedMoods[i]) {
        selectedMoods.add(Mood(id: i + 1, name: _moods[i]));
      }
    }
    return selectedMoods;
  }

  void initSelectedMoods() async {
    Diary? diary = await DiaryDatabase.instance.getDiaryById(widget.diaryId);

    if (diary!.moods.isNotEmpty) {
      diary.moods.forEach((mood) {
        print(mood.id);
        _selectedMoods[mood.id! - 1] = true;
      });
    }
    setState(() {
      _diary = diary;
      _nameController.text = diary.title;
      _contentController.text = diary.content;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    initSelectedMoods();
    super.initState();
  }

  bool vertical = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: isEditPage
            ? IconButton(
                onPressed: () {
                  DiaryDatabase.instance.deleteDiary(widget.diaryId);
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.delete_forever_rounded,
                  size: 28,
                ),
              )
            : IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.close_rounded,
                  size: 28,
                ),
              ),
        title: Text(
          'Detail Dairy',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          isEditPage
              ? InkWell(
                  onTap: () async {
                    if (_formKey.currentState!.validate()) {
                      await DiaryDatabase.instance.insertDiary(
                          Diary(
                              title: _nameController.text,
                              content: _contentController.text,
                              date: _diary!.date,
                              moods: getSelectedMoods(_moods, _selectedMoods)),
                          updateId: widget.diaryId);
                      // Navigator.of(context).pop();
                      setState(() {
                        isEditPage = false;
                      });
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Save',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color.fromRGBO(103, 74, 255, 1),
                      ),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      isEditPage = true;
                    });
                  },
                  icon: Icon(Icons.edit_rounded))
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 100,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        left: 60,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                              color: Colors.orange[700],
                              borderRadius: BorderRadius.circular(24)),
                          child:
                              Image.asset('assets/images/emoji_sleeping.png'),
                        ),
                      ),
                      Positioned(
                        left: -50,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(24)),
                          child: Image.asset('assets/images/emoji.png'),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              color: Colors.orange[300],
                              borderRadius: BorderRadius.circular(24)),
                          child: Image.asset('assets/images/emoji_grin.png'),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'Title',
                          style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black38,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        // key: _formKey,
                        controller: _nameController,
                        maxLength: 32,
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabled: isEditPage,
                            suffixIcon: isEditPage
                                ? _nameController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          _nameController.clear();
                                        },
                                        icon: Icon(Icons.close_rounded),
                                      )
                                    : null
                                : null),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Input Your Diary Title";
                          }
                          if (value.length > 32) {
                            return "Title too longgg";
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'Choose Mood',
                          style: GoogleFonts.roboto(
                              fontSize: 14,
                              color: Colors.black38,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(top: 12),
                        height: 60,
                        width: MediaQuery.of(context).size.width,
                        child: ToggleButtons(
                          direction: vertical ? Axis.vertical : Axis.horizontal,
                          onPressed: (int index) {
                            if (isEditPage) {
                              setState(() {
                                _selectedMoods[index] = !_selectedMoods[index];
                              });
                            }
                          },
                          borderRadius: BorderRadius.circular(18),
                          borderColor: Colors.transparent,
                          color: Colors.green[400],
                          renderBorder: false,
                          isSelected: _selectedMoods,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.purple[100],
                              ),
                              child:
                                  Image.asset('assets/images/emoji_grin.png'),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.orange[200],
                              ),
                              child: Image.asset('assets/images/emoji.png'),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.orange[100],
                              ),
                              child:
                                  Image.asset('assets/images/emoji_angry.png'),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.blue[50],
                              ),
                              child: Image.asset('assets/images/emoji_sad.png'),
                            ),
                            Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.orange[300],
                              ),
                              child: Image.asset(
                                  'assets/images/emoji_sleeping.png'),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        'What Happen',
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.black38,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextFormField(
                      controller: _contentController,
                      style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: 10,
                      enabled: isEditPage,
                      validator: (value) {
                        if (value!.isEmpty && value.length < 4) {
                          return "Tell Your Story";
                        }
                        return null;
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
