part of link_previewer;

class HorizontalLinkView extends StatelessWidget {
  final String url;
  final String title;
  final String description;
  final String imageUri;
  final Function onTap;
  final bool? showTitle;
  final bool? showBody;
  final TextOverflow bodyTextOverflow;
  final int? bodyMaxLines;
  final BorderRadius borderRadius;
  final TextStyle titleTextStyle;
  final TextStyle bodyTextStyle;

  HorizontalLinkView({
    Key? key,
    required this.url,
    required this.title,
    required this.description,
    required this.imageUri,
    required this.onTap,
    required this.borderRadius,
    required this.bodyTextStyle,
    required this.titleTextStyle,
    this.showTitle,
    this.showBody,
    this.bodyTextOverflow = TextOverflow.ellipsis,
    this.bodyMaxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var layoutWidth = constraints.biggest.width;
      var layoutHeight = constraints.biggest.height;

      TextStyle _titleTextStyle = titleTextStyle.copyWith(
        fontSize: titleTextStyle.fontSize ?? _computeTitleFontSize(layoutWidth),
      );

      TextStyle _bodyTextStyle = bodyTextStyle.copyWith(
        fontSize:
            bodyTextStyle.fontSize ?? (_computeTitleFontSize(layoutWidth) - 1),
      );

      return InkWell(
        onTap: () => onTap(url),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(borderRadius.topLeft.x)),
                child: imageUri == ""
                    ? Container(
                        color: Color.fromRGBO(235, 235, 235, 1.0),
                      )
                    : Container(
                        foregroundDecoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(imageUri), fit: BoxFit.cover),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                mainAxisAlignment: showBody == false
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                children: <Widget>[
                  showTitle == false
                      ? Container()
                      : _buildTitleContainer(
                          _titleTextStyle, _computeTitleLines(layoutHeight)),
                  showBody == false
                      ? Container()
                      : _buildBodyContainer(
                          _bodyTextStyle, _computeBodyLines(layoutHeight))
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  int _computeBodyLines(double layoutHeight) {
    var lines = 1;
    if (layoutHeight > 40) {
      lines += (layoutHeight - 40.0) ~/ 15.0;
    }
    return lines;
  }

  double _computeTitleFontSize(double width) {
    double size = width * 0.13;
    if (size > 15) {
      size = 15;
    }
    return size;
  }

  int _computeTitleLines(double layoutHeight) {
    return layoutHeight >= 100 ? 2 : 1;
  }

  Widget _buildBodyContainer(TextStyle textStyle, int maxLines) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 0.0),
        child: Column(
          mainAxisAlignment: showTitle == false
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                alignment: Alignment(-1.0, -1.0),
                child: Text(
                  description,
                  textAlign: TextAlign.left,
                  style: textStyle,
                  overflow: bodyTextOverflow,
                  maxLines: bodyMaxLines == null ? maxLines : bodyMaxLines,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleContainer(TextStyle textStyle, int maxLines) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 2.0, 3.0, 1.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment(-1.0, -1.0),
            child: Text(
              title,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }
}
