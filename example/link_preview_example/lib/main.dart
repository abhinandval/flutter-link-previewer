import 'package:flutter/material.dart';
import 'package:link_previewer/link_previewer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final link =
      "https://www.wired.com/story/colonial-pipeline-ransomware-attack/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Preview Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LinkPreviewer(
              url: link,
              direction: ContentDirection.horizontal,
            ),
            SizedBox(
              height: 16,
            ),
            LinkPreviewer(
              url: "https://www.linkedin.com/",
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              borderSide: BorderSide.none,
              backgroundColor: Colors.greenAccent,
              direction: ContentDirection.vertical,
            ),
          ],
        ),
      ),
    );
  }
}
