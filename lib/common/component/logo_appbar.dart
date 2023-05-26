import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoAppbar extends StatelessWidget implements PreferredSizeWidget {
  final List<IconButton>? actions;

  const LogoAppbar({
    super.key,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Text(
          'F I T E N D',
          style: GoogleFonts.audiowide(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      actions: actions,
    );
  }
}
