// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GreenRectangle extends StatelessWidget {
  final String titlePage;
  final double heightBlockTitle;
  final double topTextTitle;

  const GreenRectangle({
    super.key,
    this.titlePage = "",
    this.heightBlockTitle = 150,
    this.topTextTitle = 0.2,
  });

  static double totalHeight(
    BuildContext context, {
    double heightBlockTitle = 150,
  }) {
    return MediaQuery.of(context).padding.top + heightBlockTitle;
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // Android
        statusBarBrightness: Brightness.dark, // iOS
      ),
      child: Container(
        width: double.infinity,
        height: statusBarHeight + heightBlockTitle,
        padding: EdgeInsets.only(top: statusBarHeight),
        color: Color.fromRGBO(24, 30, 33, 1.0),
        alignment: Alignment(-0.9, topTextTitle),
        child: Text(
          titlePage,
          style: TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontFamily: 'DM Sans',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
