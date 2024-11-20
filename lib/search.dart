import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'news_page.dart';

class SearchPage extends StatelessWidget {
  final NewsAPI newsAPI;
  final Function(List<Article>) onSearch;

  const SearchPage({super.key, required this.newsAPI, required this.onSearch});

  Future<void> _navigateToHomePage(BuildContext context, String query) async {
    List<Article> newsData = await getNewsWithSearch(newsAPI, query);

    onSearch(newsData);

    if (context.mounted) {
      Navigator.pop(context);
    }
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
      body: Center(
        child: TextField(
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
              label: Text("Enter a keyword"),
              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)))),
          onSubmitted: (value) => _navigateToHomePage(context, value),
        ),
      ),
    );
  }
}
