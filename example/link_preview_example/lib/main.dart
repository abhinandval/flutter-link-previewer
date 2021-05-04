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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Link Preview Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LinkPreviewer(
            link: "https://www.linkedin.com/feed/",
            direction: ContentDirection.horizontal,
          ),
          LinkPreviewer(
            link: "https://www.linkedin.com/feed/",
            direction: ContentDirection.vertical,
          ),
        ],
      ),
    );
  }
}
