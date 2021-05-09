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
  final String url;
  final Color backgroundColor;
  final Color defaultPlaceholderColor;
  final ContentDirection direction;
  final Widget? placeholder;
  final bool showTitle;
  final bool showBody;
  final TextOverflow bodyTextOverflow;
  final int? bodyMaxLines;
  final BorderRadius borderRadius;
  final BorderSide borderSide;
  final TextStyle titleTextStyle;
  final TextStyle bodyTextStyle;
  final Widget? loadingIndicator;

  LinkPreviewer({
    Key? key,
    required this.url,
    this.backgroundColor = Colors.white,
    this.defaultPlaceholderColor = const Color.fromRGBO(235, 235, 235, 1.0),
    this.placeholder,
    this.showTitle = true,
    this.showBody = true,
    this.direction = ContentDirection.horizontal,
    TextOverflow? bodyTextOverflow,
    this.bodyMaxLines,
    this.borderRadius = const BorderRadius.all(
      const Radius.circular(3.0),
    ),
    this.borderSide = const BorderSide(
      color: Colors.deepOrangeAccent,
      width: 1.0,
    ),
    this.titleTextStyle = const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    this.bodyTextStyle = const TextStyle(
      color: Colors.grey,
    ),
    this.loadingIndicator,
  })  : this.bodyTextOverflow = bodyTextOverflow ??
            (direction == ContentDirection.horizontal
                ? TextOverflow.ellipsis
                : TextOverflow.fade),
        super(key: key);

  @override
  _LinkPreviewer createState() => _LinkPreviewer();
}

class _LinkPreviewer extends State<LinkPreviewer> {
  late String _link;
  late double _height;
  final Completer<Map> _metaDataCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    _height = _computeHeight(MediaQuery.of(context).size.height);

    return FutureBuilder<Map<dynamic, dynamic>>(
      future: _metaDataCompleter.future,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return _buildLinkContainer(snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        } else {
          return _buildPlaceHolder(widget.defaultPlaceholderColor, _height);
        }
      },
    );
  }

  @override
  void initState() {
    _link = widget.url.trim();
    _buildMetaData();
    super.initState();
  }

  BoxDecoration _buildDecoration([Color? color]) => BoxDecoration(
        color: color ?? widget.backgroundColor,
        border: Border.fromBorderSide(widget.borderSide),
        borderRadius: widget.borderRadius,
      );

  Widget _buildLinkContainer(Map<dynamic, dynamic> metaData) {
    return Container(
      decoration: _buildDecoration(),
      height: _height,
      child: _buildLinkView(
          _link,
          metaData['title'] ?? "",
          metaData['description'] ?? "",
          metaData['image'] ?? "",
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
    BorderRadius borderRadius,
  ) {
    if (widget.direction == ContentDirection.horizontal) {
      return HorizontalLinkView(
        url: link,
        title: title,
        description: description,
        imageUri: imageUri,
        onTap: onTap,
        showTitle: showTitle,
        showBody: showBody,
        bodyTextOverflow: widget.bodyTextOverflow,
        bodyMaxLines: widget.bodyMaxLines,
        borderRadius: borderRadius,
        bodyTextStyle: widget.bodyTextStyle,
        titleTextStyle: widget.titleTextStyle,
      );
    } else {
      return VerticalLinkPreview(
        url: link,
        title: title,
        description: description,
        imageUri: imageUri,
        onTap: onTap,
        showTitle: showTitle,
        showBody: showBody,
        bodyTextOverflow: widget.bodyTextOverflow,
        bodyMaxLines: widget.bodyMaxLines,
        borderRadius: borderRadius,
        bodyTextStyle: widget.bodyTextStyle,
        titleTextStyle: widget.titleTextStyle,
      );
    }
  }

  Widget _buildLoadingIndicator() {
    if (widget.loadingIndicator != null) {
      return widget.loadingIndicator!;
    } else {
      return Center(child: CircularProgressIndicator.adaptive());
    }
  }

  void _buildMetaData() {
    if (_link.isValidUrl) {
      WebPageParser.getData(_link).then((metaData) {
        _metaDataCompleter.complete(metaData);
      }, onError: (exception, stackTrace) {
        _metaDataCompleter.completeError(exception, stackTrace);
      });
    } else {
      _metaDataCompleter.completeError(Exception("LinkPreviewer: Invalid url"));
    }
  }

  Widget _buildPlaceHolder(Color color, double defaultHeight) {
    return widget.placeholder ??
        Container(
          height: defaultHeight,
          child: LayoutBuilder(builder: (context, constraints) {
            double layoutWidth = constraints.biggest.width;
            double layoutHeight = constraints.biggest.height;

            return Container(
              decoration: _buildDecoration(color),
              width: layoutWidth,
              height: layoutHeight,
            );
          }),
        );
  }

  double _computeHeight(double screenHeight) {
    if (widget.direction == ContentDirection.horizontal) {
      return screenHeight * 0.12;
    } else {
      return screenHeight * 0.25;
    }
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

extension on String {
  bool get isValidUrl {
    String regexSource =
        "^(https?)://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|]";
    final regex = RegExp(regexSource);
    final matches = regex.allMatches(this);
    for (Match match in matches) {
      if (match.start == 0 && match.end == this.length) {
        return true;
      }
    }
    return false;
  }
}
