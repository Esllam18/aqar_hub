import 'package:aqar_hub/core/services/responsive/responsive_extension.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrDividerWidget extends StatelessWidget {
  final String text;
  const OrDividerWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.4))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: context.r(12)),
          child: Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: context.sp(13),
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.4))),
      ],
    );
  }
}
