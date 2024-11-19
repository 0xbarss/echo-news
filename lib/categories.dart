import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:news_api_flutter_package/model/article.dart';

class CategoriesPage extends StatelessWidget {
  final List<String> categories = [
    'business',
    'entertainment',
    'general',
    'health',
    'science',
    'sports',
    'technology',
  ];

  CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            String category = categories[index];
            return InkWell(
                onTap: () {},
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text(category)],
                  ),
                ));
          }),
    );
  }
}
