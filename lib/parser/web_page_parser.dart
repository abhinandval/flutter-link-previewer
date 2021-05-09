part of link_previewer;

class WebPageParser {
  static Future<Map> getData(String url) async {
    var response = await http.get(Uri.parse(url));
    return getDataFromResponse(response, url);
  }

  static Map<dynamic, dynamic> getDataFromResponse(
    http.Response response,
    String url,
  ) {
    List<String> requiredAttributes = ['title', 'image'];
    Map data = {};
    if (response.statusCode == 200) {
      Document document = parser.parse(response.body);
      List<Element> openGraphMetaTags = _getOgPropertyData(document);
      openGraphMetaTags.forEach((element) {
        String? ogTagTitle = element.attributes['property']?.split("og:")[1];
        String? ogTagValue = element.attributes['content'];
        if ((ogTagValue != null && ogTagValue != "") ||
            requiredAttributes.contains(ogTagTitle)) {
          if (ogTagTitle == "image" && (!ogTagValue!.startsWith("http"))) {
            data[ogTagTitle] = "https://" + _extractHost(url) + ogTagValue;
          } else {
            data[ogTagTitle] = ogTagValue;
          }
        }
      });
      _scrapeDataToEmptyValue(data, document, url);
    }
    return data;
  }

  static String _extractHost(String link) {
    Uri uri = Uri.parse(link);
    return uri.host;
  }

  static void _scrapeDataToEmptyValue(Map data, Document document, String url) {
    if (!data.containsKey("title") ||
        data["title"] == null ||
        data["title"] == "") {
      data["title"] = _scrapeTitle(document);
    }

    if (!data.containsKey("image") ||
        data["image"] == null ||
        data["image"] == "") {
      data["image"] = _scrapeImage(document, url);
    }

    if (!data.containsKey("description") ||
        data["description"] == null ||
        data["description"] == "") {}
    data["description"] = _scrapeDescription(document);
  }

  static String _scrapeTitle(Document document) {
    List<Element> titleTags =
        document.head?.getElementsByTagName("title") ?? [];
    if (titleTags.isNotEmpty) {
      return titleTags.first.text;
    }
    return "";
  }

  static String _scrapeDescription(Document document) {
    List<Element> meta = document.getElementsByTagName("meta");
    String? description = "";
    Element? metaDescription =
        meta.firstWhereOrNull((e) => e.attributes["name"] == "description");

    if (metaDescription != null) {
      description = metaDescription.attributes["content"];
      if (description != null && description != "") {
        return description;
      } else {
        description = document.head?.getElementsByTagName("title")[0].text;
      }
    }

    return description ?? "";
  }

  static String? _scrapeImage(Document document, String url) {
    List<Element> images = document.body?.getElementsByTagName("img") ?? [];
    String imageSrc = "";
    if (images.length > 0) {
      imageSrc = images[0].attributes["src"] ?? "";

      if (!imageSrc.startsWith("http")) {
        imageSrc = "https://" + _extractHost(url) + imageSrc;
      }
    }
    if (imageSrc == "") {
      print("WARNING - WebPageParser - " + url);
      print(
          "WARNING - WebPageParser - image might be empty. Tag <img> was not found.");
    }
    return imageSrc;
  }

  static List<Element> _getOgPropertyData(Document document) {
    return document.head?.querySelectorAll("[property*='og:']") ?? [];
  }

  static String _addWWWPrefixIfNotExists(String uri) {
    final parsedUri = Uri.tryParse(uri);
    if (parsedUri != null) {
      if (!parsedUri.host.startsWith('www')) {
        return (parsedUri.replace(host: 'www.' + parsedUri.host)).toString();
      } else {
        return parsedUri.toString();
      }
    } else {
      return uri;
    }
  }
}
