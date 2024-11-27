import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'news_page.dart';

class SearchPage extends StatefulWidget {
  final NewsAPI newsAPI;
  final Function(List<Article>) onSearch;

  const SearchPage({super.key, required this.newsAPI, required this.onSearch});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController textEditingController = TextEditingController();
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

  Future<void> _navigateToHomePage(BuildContext context, String query) async {
    List<Article> newsData = await getNewsWithSearch(widget.newsAPI, query,
        fromDate: fromDate, toDate: toDate, sortBy: sortBy);

    widget.onSearch(newsData);

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
      body: Column(
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
            controller: textEditingController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.arrow_back_sharp),
                label: Text("Enter a keyword"),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)))),
            onSubmitted: (value) => _navigateToHomePage(context, value),
          )
        ],
      ),
    );
  }
}
