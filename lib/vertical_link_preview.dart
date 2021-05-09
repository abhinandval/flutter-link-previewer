part of link_previewer;

class VerticalLinkPreview extends StatelessWidget {
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
  VerticalLinkPreview({
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
    this.bodyTextOverflow = TextOverflow.fade,
    this.bodyMaxLines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var layoutWidth = constraints.biggest.width;
      var layoutHeight = constraints.biggest.height;

      TextStyle _titleTextStyle = titleTextStyle.copyWith(
        fontSize: titleTextStyle.fontSize ?? computeTitleFontSize(layoutWidth),
      );

      TextStyle _bodyTextStyle = bodyTextStyle.copyWith(
        fontSize:
            bodyTextStyle.fontSize ?? (computeTitleFontSize(layoutWidth) - 1),
      );

      return InkWell(
          onTap: () => onTap(url),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(borderRadius.topLeft.x)),
                  child: imageUri == ""
                      ? Container(
                          color: Color.fromRGBO(235, 235, 235, 1.0),
                        )
                      : Container(
                          foregroundDecoration: BoxDecoration(
                            image: DecorationImage(
                                image: NetworkImage(imageUri),
                                fit: layoutHeight >= layoutWidth
                                    ? BoxFit.cover
                                    : BoxFit.fitWidth),
                          ),
                        ),
                ),
              ),
              showTitle == false
                  ? Container()
                  : _buildTitleContainer(_titleTextStyle,
                      computeTitleLines(layoutHeight, layoutWidth)),
              showBody == false
                  ? Container()
                  : _buildBodyContainer(
                      _bodyTextStyle, computeBodyLines(layoutHeight)),
            ],
          ));
    });
  }

  int computeBodyLines(double layoutHeight) {
    return layoutHeight ~/ 60 == 0 ? 1 : layoutHeight ~/ 60;
  }

  double computeTitleFontSize(double height) {
    double size = height * 0.13;
    if (size > 15) {
      size = 15;
    }
    return size;
  }

  int computeTitleLines(double layoutHeight, double layoutWidth) {
    return layoutHeight - layoutWidth < 50 ? 1 : 2;
  }

  Widget _buildBodyContainer(TextStyle textStyle, int maxLines) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 4.0),
        child: Container(
          alignment: Alignment(-1.0, -1.0),
          child: Text(
            description,
            style: textStyle,
            overflow: bodyTextOverflow,
            maxLines: bodyMaxLines == null ? maxLines : bodyMaxLines,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleContainer(TextStyle textStyle, int maxLines) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 1.0, 3.0, 0.0),
      child: Container(
        alignment: Alignment(-1.0, -1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ],
        ),
      ),
    );
  }
}
