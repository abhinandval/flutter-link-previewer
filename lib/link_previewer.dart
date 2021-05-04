library link_previewer;

import 'dart:async';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

part 'package:link_previewer/content_direction.dart';

part 'package:link_previewer/horizontal_link_view.dart';

part 'package:link_previewer/vertical_link_preview.dart';

part 'parser/web_page_parser.dart';

class LinkPreviewer extends StatefulWidget {
  LinkPreviewer({
    Key? key,
    required this.link,
    this.titleFontSize,
    this.bodyFontSize,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.deepOrangeAccent,
    this.titleTextColor = Colors.black,
    this.bodyTextColor = Colors.grey,
    this.defaultPlaceholderColor = const Color.fromRGBO(235, 235, 235, 1.0),
    this.borderRadius = 3.0,
    this.placeholder,
    this.showTitle = true,
    this.showBody = true,
    this.direction = ContentDirection.horizontal,
    this.bodyTextOverflow,
    this.bodyMaxLines,
  }) : super(key: key);

  final String link;
  final double? titleFontSize;
  final double? bodyFontSize;
  final Color backgroundColor;
  final Color borderColor;
  final Color defaultPlaceholderColor;
  final Color titleTextColor;
  final Color bodyTextColor;
  final double borderRadius;
  final ContentDirection direction;
  final Widget? placeholder;
  final bool showTitle;
  final bool showBody;
  final TextOverflow? bodyTextOverflow;
  final int? bodyMaxLines;

  @override
  _LinkPreviewer createState() => _LinkPreviewer();
}

class _LinkPreviewer extends State<LinkPreviewer> {
  late final Map _metaData;
  late final double _height;
  late final String _link;
  bool _failedToLoadImage = false;

  @override
  void initState() {
    super.initState();
    _link = widget.link.trim();
    if (_link.startsWith("https")) {
      _link = "http" + _link.split("https")[1];
    }
    _fetchData();
  }

  double _computeHeight(double screenHeight) {
    if (widget.direction == ContentDirection.horizontal) {
      return screenHeight * 0.12;
    } else {
      return screenHeight * 0.25;
    }
  }

  void _fetchData() {
    if (!isValidUrl(_link)) {
      throw Exception("Invalid link");
    } else {
      _getMetaData(_link);
    }
  }

  void _validateImageUri(String uri) {
    precacheImage(NetworkImage(uri), context, onError: (e, stackTrace) {
      setState(() {
        _failedToLoadImage = true;
      });
    });
  }

  String _getUriWithPrefix(String uri) {
    return WebPageParser._addWWWPrefixIfNotExists(uri);
  }

  void _getMetaData(String link) async {
    Map data = await WebPageParser.getData(link);
    _validateImageUri(data['image']);
    setState(() {
      _metaData = data;
    });
  }

  bool isValidUrl(String link) {
    String regexSource =
        "^(https?)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
    final regex = RegExp(regexSource);
    final matches = regex.allMatches(link);
    for (Match match in matches) {
      if (match.start == 0 && match.end == link.length) {
        return true;
      }
    }
    return false;
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double _height = _computeHeight(MediaQuery.of(context).size.height);

    return _metaData.isEmpty
        ? widget.placeholder == null
            ? _buildPlaceHolder(widget.defaultPlaceholderColor, _height)
            : widget.placeholder!
        : _buildLinkContainer();
  }

  Widget _buildPlaceHolder(Color color, double defaultHeight) {
    return Container(
      height: defaultHeight,
      child: LayoutBuilder(builder: (context, constraints) {
        double layoutWidth = constraints.biggest.width;
        double layoutHeight = constraints.biggest.height;

        return Container(
          decoration: new BoxDecoration(
            color: color,
            border: Border.all(
              color: widget.borderColor,
              width: 1.0,
            ),
            borderRadius:
                BorderRadius.all(Radius.circular(widget.borderRadius)),
          ),
          width: layoutWidth,
          height: layoutHeight,
        );
      }),
    );
  }

  Widget _buildLinkContainer() {
    return Container(
      decoration: new BoxDecoration(
        color: widget.backgroundColor,
        border: Border.all(
          color: widget.borderColor,
          width: 1.0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius)),
      ),
      height: _height,
      child: _buildLinkView(
          _link,
          _metaData['title'] == null ? "" : _metaData['title'],
          _metaData['description'] == null ? "" : _metaData['description'],
          _metaData['image'] == null ? "" : _metaData['image'],
          _launchURL,
          widget.showTitle,
          widget.showBody,
          widget.borderRadius),
    );
  }

  Widget _buildLinkView(
    String link,
    String title,
    String description,
    String imageUri,
    ValueChanged<String> onTap,
    bool showTitle,
    bool showBody,
    double borderRadius,
  ) {
    if (widget.direction == ContentDirection.horizontal) {
      return HorizontalLinkView(
        url: link,
        title: title,
        description: description,
        imageUri: _failedToLoadImage == false
            ? imageUri
            : _getUriWithPrefix(imageUri),
        onTap: onTap,
        showTitle: showTitle,
        showBody: showBody,
        bodyTextOverflow: widget.bodyTextOverflow!,
        bodyMaxLines: widget.bodyMaxLines,
        titleTextColor: widget.titleTextColor,
        bodyTextColor: widget.bodyTextColor,
        borderRadius: borderRadius,
      );
    } else {
      return VerticalLinkPreview(
        url: link,
        title: title,
        description: description,
        imageUri: _failedToLoadImage == false
            ? imageUri
            : _getUriWithPrefix(imageUri),
        onTap: onTap,
        showTitle: showTitle,
        showBody: showBody,
        bodyTextOverflow: widget.bodyTextOverflow!,
        bodyMaxLines: widget.bodyMaxLines,
        titleTextColor: widget.titleTextColor,
        bodyTextColor: widget.bodyTextColor,
        borderRadius: borderRadius,
      );
    }
  }
}
