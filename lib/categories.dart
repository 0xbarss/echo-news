import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'news_page.dart';

class CategoriesPage extends StatelessWidget {
  final NewsAPI newsAPI;
  final Function(List<Article>) onCategorySelected;

  CategoriesPage({super.key, required this.newsAPI, required this.onCategorySelected});

  final List<String> categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology'
  ];

  Future<void> _navigateToSelectedCategoryPage(
      BuildContext context, String category) async {
    List<Article> newsData =
        await getNewsWithCategory(newsAPI, category: category);

    onCategorySelected(newsData);

    if (context.mounted) {
      Navigator.pop(context);
    }
    // if (context.mounted) {
    //   Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //           builder: (context) => NewsPage(newsData: newsData)));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Echo News',
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
      body: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return InkWell(
              child: ListTile(
                title: Text(categories[index]),
                onTap: () => _navigateToSelectedCategoryPage(context, categories[index]),
              ),
            );
          }),
    );
  }
}
