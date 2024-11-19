import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'news_page.dart';

class HomePage extends StatelessWidget {
  final List<Article> newsData;
  const HomePage({super.key, required this.newsData});

  @override
  Widget build(BuildContext context) {
    return NewsPage(newsData: newsData);
  }
}
