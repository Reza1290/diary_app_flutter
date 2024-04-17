import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotFound extends StatelessWidget {
  const NotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/images/emoji.png'),
          Text(
            'Tell Me Your Story!',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          )
        ],
      ),
    );
  }
}
