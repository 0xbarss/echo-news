import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'news.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  DateTime? fromDate;
  DateTime? toDate;
  String sortBy = "publishedAt";
  final Map<String, String> sortOptions = {
    'relevancy': 'Relevancy',
    'popularity': 'Popularity',
    'publishedAt': 'Published At'
  };

  Future<void> pickDate(BuildContext context, bool isFrom) async {
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now());
    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  Future<void> _navigateToSearchedContentPage(BuildContext context, String query) async {
    final NewsAPI newsAPI = NewsAPIProvider.of(context).newsAPI;
    List<Article> newsData = await getNewsWithSearch(newsAPI, query,
        fromDate: fromDate, toDate: toDate, sortBy: sortBy);

    if (context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SearchContentPage(query: query, newsData: newsData)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text("From Date"),
          subtitle: Text(fromDate == null
              ? "Select a date"
              : DateFormat('yyyy-MM-dd').format(fromDate!)),
          trailing: const Icon(Icons.arrow_back_ios),
          onTap: () => pickDate(context, true),
        ),
        ListTile(
          leading: const Icon(Icons.date_range),
          title: const Text("To Date"),
          subtitle: Text(toDate == null
              ? "Select a date"
              : DateFormat('yyyy-MM-dd').format(toDate!)),
          trailing: const Icon(Icons.arrow_back_ios),
          onTap: () => pickDate(context, false),
        ),
        Row(
          children: [
            const SizedBox(
              width: 16,
            ),
            const Icon(Icons.sort),
            const SizedBox(
              width: 16,
            ),
            DropdownButton<String>(
              value: sortBy,
              items: sortOptions.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (String? value) {
                if (value != null) {
                  setState(() {
                    sortBy = value;
                  });
                }
              },
            )
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        TextField(
          showCursor: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              suffixIcon: Icon(Icons.arrow_back_sharp),
              label: Text("Enter a keyword"),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)))),
          onSubmitted: (value) => _navigateToSearchedContentPage(context, value),
        )
      ],
    );
  }
}

class SearchContentPage extends StatelessWidget {
  final String query;
  final List<Article> newsData;

  const SearchContentPage(
      {super.key, required this.query, required this.newsData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(query,
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
