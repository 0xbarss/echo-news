import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

class NewsAPIProvider extends InheritedWidget {
  final NewsAPI newsAPI;

  const NewsAPIProvider(
      this.newsAPI, {
        super.key,
        required super.child,
      });

  static NewsAPIProvider of(BuildContext context) {
    final NewsAPIProvider? result =
    context.dependOnInheritedWidgetOfExactType<NewsAPIProvider>();
    assert(result != null, 'No NewsAPIProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(NewsAPIProvider oldWidget) {
    return newsAPI != oldWidget.newsAPI;
  }
}