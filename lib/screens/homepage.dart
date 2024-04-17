import 'package:catatan_masa_depan/components/not_found.dart';
import 'package:catatan_masa_depan/models/detail_dairy.dart';
import 'package:catatan_masa_depan/screens/create_diary.dart';
import 'package:catatan_masa_depan/screens/detail_diary_screen.dart';
import 'package:catatan_masa_depan/screens/show_all_diary_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:catatan_masa_depan/database.dart';
import 'package:catatan_masa_depan/models/diary.dart';
import 'package:catatan_masa_depan/models/mood.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello',
                style: GoogleFonts.roboto(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DatePicker(
                      height: 90,
                      DateTime.now().add(const Duration(days: -2)),
                      monthTextStyle: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                      dateTextStyle: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 209, 207, 243)),
                      dayTextStyle: GoogleFonts.roboto(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 12),
                      // activeDates: [DateTime(year)],

                      initialSelectedDate: DateTime.now(),
                      selectionColor: Color.fromRGBO(134, 110, 255, 1),
                      selectedTextColor: Colors.white,
                      locale: 'id_Id',
                      onDateChange: (date) {
                        // New date selected
                        print(date);
                        setState(() {
                          selectedDate = date;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'What i do',
                    style: GoogleFonts.roboto(
                        fontWeight: FontWeight.w800,
                        color: Colors.black54,
                        fontSize: 14),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShowAllScreen(),
                        )),
                    child: Text(
                      'Memories',
                      style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          color: Colors.blueAccent.shade100,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
              FutureBuilder<List<Diary>>(
                future: DiaryDatabase.instance
                    .getDiariesByDate(selectedDate, limit: 2),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return NotFound();
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return NotFound();
                  }

                  final diaries = snapshot.data!;
                  return Column(
                    children: diaries.map((diary) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 20),
                        width: MediaQuery.of(context).size.width,
                        // height: 180,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            // border: Border.all(width: 2),
                            color: diary.id! % 2 == 0
                                ? Color.fromRGBO(251, 248, 255, 1)
                                : Color.fromRGBO(255, 245, 243, 1)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(26),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailDairyScreen(diaryId: diary.id ?? 1),
                                ));
                          },
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.centerLeft,
                            children: [
                              Positioned(
                                left: -3,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: diary.id! % 2 == 0
                                          ? Color.fromRGBO(223, 186, 255, 1)
                                          : Color.fromRGBO(255, 163, 128, 1),
                                      borderRadius: BorderRadius.circular(100)),
                                  width: 8,
                                  height:
                                      MediaQuery.of(context).size.height / 10,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(right: 16),
                                          padding: EdgeInsets.all(6),
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: diary.id! % 2 == 0
                                                ? Color.fromRGBO(
                                                    223, 186, 255, 1)
                                                : Color.fromRGBO(
                                                    255, 163, 128, 1),
                                          ),
                                          child: Image.asset(
                                            diary.moods.isEmpty
                                                ? "assets/images/emoji.png"
                                                : "assets/images/${moodNameToPath[diary.moods.first.name]}.png",
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                diary.title,
                                                style: GoogleFonts.roboto(
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.black87,
                                                  fontSize: 18,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                  diary.moods.isEmpty
                                                      ? 'Normal'
                                                      : diary.moods.first.name,
                                                  style: GoogleFonts.roboto(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.black54,
                                                      fontSize: 16),
                                                  overflow:
                                                      TextOverflow.ellipsis)
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(top: 10),
                                      child: Text(
                                        diary.content,
                                        maxLines: 3,
                                        style: GoogleFonts.roboto(
                                            color: Colors.black45,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateDiary(
                  diaryDate: selectedDate,
                ),
              ));
          setState(() {});
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
