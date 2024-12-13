import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'news.dart';

class CategoriesPage extends StatelessWidget {
  CategoriesPage({super.key});

  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology'
  ];

  final List<IconData> categoryIcons = [
    Icons.newspaper,
    Icons.business,
    Icons.tv,
    Icons.health_and_safety_rounded,
    Icons.science,
    Icons.sports,
    Icons.memory
  ];

  Future<void> _navigateToSelectedCategoryPage(
      BuildContext context, String category) async {
    final NewsAPI newsAPI = NewsAPIProvider.of(context).newsAPI;
    List<Article> newsData =
        await getNewsWithCategory(newsAPI, category: category);

    if (context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoryContentPage(
                  category: toBeginningOfSentenceCase(category),
                  newsData: newsData)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Card(
              child: ListTile(
                leading: Icon(categoryIcons[index]),
                trailing: const Icon(Icons.arrow_back_ios_new),
                title: Text(toBeginningOfSentenceCase(categories[index])),
                onTap: () =>
                    _navigateToSelectedCategoryPage(context, categories[index]),
              ),
            ),
          );
        });
  }
}

class CategoryContentPage extends StatelessWidget {
  final String category;
  final List<Article> newsData;

  const CategoryContentPage(
      {super.key, required this.category, required this.newsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category,
            style: GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w800)),
        flexibleSpace: const FlexibleSpaceBar(
          background: DecoratedBox(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.red, Colors.orange],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft))),
        ),
        centerTitle: true,
      ),
      body: NewsPage(newsData: newsData),
    );
  }
}
