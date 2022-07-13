import 'dart:io';

import 'package:flutter/material.dart';

class ShowImageResultPage extends StatefulWidget {

  final String filePath;
  const ShowImageResultPage({Key? key,required this.filePath}) : super(key: key);

  @override
  _ShowImageResultPageState createState() => _ShowImageResultPageState();
}

class _ShowImageResultPageState extends State<ShowImageResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("合成后的图片"),),
      body: Center(
        child: Image.file(File(widget.filePath)),
      ),
    );
  }
}
