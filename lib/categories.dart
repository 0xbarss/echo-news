import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:intl/intl.dart';
import 'news.dart';
import 'news_api_provider.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final List<String> _categories = [
    'general',
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology'
  ];
  final List<IconData> _categoryIcons = [
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
    List<News> newsData =
        await getNewsWithCategory(newsAPI, category: category);

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryContentPage(
              category: toBeginningOfSentenceCase(category),
              newsData: newsData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          return InkWell(
            child: Card(
              child: ListTile(
                leading: Icon(_categoryIcons[index]),
                trailing: const Icon(Icons.arrow_forward_ios),
                title: Text(toBeginningOfSentenceCase(_categories[index])),
                onTap: () => _navigateToSelectedCategoryPage(
                    context, _categories[index]),
              ),
            ),
          );
        });
  }
}

class CategoryContentPage extends StatelessWidget {
  final String category;
  final List<News> newsData;

  const CategoryContentPage(
      {super.key, required this.category, required this.newsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category, style: Theme.of(context).textTheme.headlineSmall),
        flexibleSpace: const FlexibleSpaceBar(
          background: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: NewsPage(newsData: newsData),
    );
  }
}
