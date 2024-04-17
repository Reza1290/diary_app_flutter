import 'package:catatan_masa_depan/components/not_found.dart';
import 'package:catatan_masa_depan/database.dart';
import 'package:catatan_masa_depan/models/diary.dart';
import 'package:catatan_masa_depan/models/mood.dart';
import 'package:catatan_masa_depan/screens/detail_diary_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class ShowAllScreen extends StatefulWidget {
  const ShowAllScreen({super.key});

  @override
  State<ShowAllScreen> createState() => _ShowAllScreenState();
}

class _ShowAllScreenState extends State<ShowAllScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 80,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 28,
          ),
        ),
        title: Text(
          'Memories',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              FutureBuilder<Map<String, List<Diary>>>(
                future: DiaryDatabase.instance.getMemories(),
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
                    children: diaries.entries.map((entry) {
                      final String date = entry.key;
                      final List<Diary> diariesForDate = entry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            date, // Format date as desired
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: diariesForDate.map((diary) {
                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 20),
                                  width:
                                      MediaQuery.of(context).size.width * 4 / 5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(28),
                                    color: diary.id! % 2 == 0
                                        ? Color.fromRGBO(251, 248, 255, 1)
                                        : Color.fromRGBO(255, 245, 243, 1),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(26),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetailDairyScreen(
                                                  diaryId: diary.id ?? 1),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        Positioned(
                                          top: 0,
                                          left: -24,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: diary.id! % 2 == 0
                                                  ? Color.fromRGBO(
                                                      223, 186, 255, 1)
                                                  : Color.fromRGBO(
                                                      255, 163, 128, 1),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            width: 12,
                                            height: 12,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(24),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.only(
                                                        right: 16),
                                                    padding: EdgeInsets.all(6),
                                                    width: 54,
                                                    height: 54,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
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
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          diary.title,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w900,
                                                            color:
                                                                Colors.black87,
                                                            fontSize: 18,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        Text(
                                                          diary.moods.isEmpty
                                                              ? 'Normal'
                                                              : diary.moods
                                                                  .first.name,
                                                          style: GoogleFonts
                                                              .roboto(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                Colors.black54,
                                                            fontSize: 16,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: Text(
                                                  diary.content,
                                                  maxLines: 10,
                                                  style: GoogleFonts.roboto(
                                                    color: Colors.black45,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
