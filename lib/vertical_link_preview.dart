part of link_previewer;

class VerticalLinkPreview extends StatelessWidget {
  VerticalLinkPreview({
    Key? key,
    required this.url,
    required this.title,
    required this.description,
    required this.imageUri,
    required this.onTap,
    this.titleFontSize,
    this.bodyFontSize,
    this.showTitle,
    this.showBody,
    this.bodyTextOverflow = TextOverflow.fade,
    this.bodyMaxLines,
    this.titleTextColor,
    this.bodyTextColor,
    this.borderRadius = 3.0,
  }) : super(key: key);

  final String url;
  final String title;
  final String description;
  final String imageUri;
  final Function onTap;
  final double? titleFontSize;
  final double? bodyFontSize;
  final bool? showTitle;
  final bool? showBody;
  final TextOverflow bodyTextOverflow;
  final int? bodyMaxLines;
  final Color? titleTextColor;
  final Color? bodyTextColor;
  final double borderRadius;

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

  int computeBodyLines(double layoutHeight) {
    return layoutHeight ~/ 60 == 0 ? 1 : layoutHeight ~/ 60;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var layoutWidth = constraints.biggest.width;
      var layoutHeight = constraints.biggest.height;

      var _titleFontSize = titleFontSize == null
          ? computeTitleFontSize(layoutHeight)
          : titleFontSize;
      var _bodyFontSize = bodyFontSize == null
          ? computeTitleFontSize(layoutHeight) - 1
          : bodyFontSize;

      return InkWell(
          onTap: () => onTap(url),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(borderRadius)),
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
                  : _buildTitleContainer(_titleFontSize,
                      computeTitleLines(layoutHeight, layoutWidth)),
              showBody == false
                  ? Container()
                  : _buildBodyContainer(
                      _bodyFontSize, computeBodyLines(layoutHeight)),
            ],
          ));
    });
  }

  Widget _buildTitleContainer(double? titleFontSize, int maxLines) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4.0, 1.0, 3.0, 0.0),
      child: Container(
        alignment: Alignment(-1.0, -1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: titleFontSize,
                  color: titleTextColor),
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContainer(double? bodyFontSize, int maxLines) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5.0, 2.0, 5.0, 4.0),
        child: Container(
          alignment: Alignment(-1.0, -1.0),
          child: Text(
            description,
            style: TextStyle(fontSize: bodyFontSize, color: bodyTextColor),
            overflow: bodyTextOverflow,
            maxLines: bodyMaxLines == null ? maxLines : bodyMaxLines,
          ),
        ),
      ),
    );
  }
}
