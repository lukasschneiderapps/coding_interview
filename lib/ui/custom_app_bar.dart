import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {

  final String title;

  CustomAppBar(this.title);

  @override
  State<StatefulWidget> createState() {
    return _CustomAppBarState();
  }

  @override
  Size get preferredSize => null;

}

class _CustomAppBarState extends State<CustomAppBar> {

  @override
  Widget build(BuildContext context) =>
      AppBar(
          centerTitle: true,
          title: Text(widget.title,
              style: TextStyle(
                  color: Colors.white, fontSize: 30, fontFamily: 'Kirvy')));

}