import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

List<News> organizeArticles(List<Article> newsData) {
  return newsData
      .map(
        (article) => News(
          article.author ?? 'Unknown Author',
          article.title ?? 'No Title',
          article.description ?? 'No Description',
          article.url ?? 'No URL',
          article.urlToImage ??
              'https://i0.wp.com/poolpromag.com/wp-content/uploads/2020/02/News-Placeholder.jpg',
          article.publishedAt ?? DateTime.now().toString(),
          article.content ?? '',
        ),
      )
      .where((article) => article.title != '[Removed]')
      .toList();
}

Future<List<News>> getNewsWithSearch(NewsAPI newsAPI, String query,
    {DateTime? fromDate, DateTime? toDate, String? sortBy}) async {
  List<Article> fetchedNewsData = [];
  try {
    fetchedNewsData = await newsAPI.getEverything(
      query: query,
      from: fromDate,
      to: toDate,
      language: 'en',
      sortBy: sortBy,
    );
    return organizeArticles(fetchedNewsData);
  } catch (e) {
    //print("Error $e);
  }
  return [];
}

Future<List<News>> getNewsWithCategory(NewsAPI newsAPI,
    {String category = "general"}) async {
  List<Article> fetchedNewsData = [];
  try {
    fetchedNewsData =
        await newsAPI.getTopHeadlines(country: "us", category: category);
    return organizeArticles(fetchedNewsData);
  } catch (e) {
    //print("Error $e");
  }
  return [];
}

class News {
  final String author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content;

  News(
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  );

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      json["author"],
      json["title"],
      json["description"],
      json["url"],
      json["urlToImage"],
      json["publishedAt"],
      json["content"],
    );
  }

  static List<News> parseList(dynamic list) {
    if (list == null || list is! List || list.isEmpty) return [];
    return list.map((e) => News.fromJson(e)).toList();
  }

  Map<String, String> toJson() {
    return {
      "author": author,
      "title": title,
      "description": description,
      "url": url,
      "urlToImage": urlToImage,
      "publishedAt": publishedAt,
      "content": content,
    };
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final String _placeHolderImage = 'assets/images/news-placeholder.jpg';

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Image.network(
              news.urlToImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image(
                    image: AssetImage(_placeHolderImage), fit: BoxFit.cover);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              news.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsContentPage extends StatefulWidget {
  final News news;

  const NewsContentPage({super.key, required this.news});

  @override
  State<NewsContentPage> createState() => _NewsContentPageState();
}

class _NewsContentPageState extends State<NewsContentPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _placeHolderImage = 'assets/images/news-placeholder.jpg';
  bool _savedToBookmarks = false;

  @override
  void initState() {
    super.initState();
    _fetchBookmarkStatus();
  }

  Future<void> _shareLink() async => await Share.share(
        widget.news.url,
        subject: widget.news.title,
      );

  Future<void> _manageBookmark() async {
    if (!_savedToBookmarks) {
      final String bookmarkID = widget.news.title;
      final Map<String, String> article = {
        "author": widget.news.author,
        "title": widget.news.title,
        "description": widget.news.description,
        "url": widget.news.url,
        "urlToImage": widget.news.urlToImage,
        "publishedAt": widget.news.publishedAt,
        "content": widget.news.content,
      };
      await db
          .collection("users")
          .doc(user!.uid)
          .collection("bookmarks")
          .doc(bookmarkID)
          .set(article);
    } else {
      await db
          .collection("users")
          .doc(user!.uid)
          .collection("bookmarks")
          .doc(widget.news.title)
          .delete();
    }
  }

  void _onPressBookmark() {
    _manageBookmark();
    setState(() {
      _savedToBookmarks = !_savedToBookmarks;
    });
  }

  Future<void> _fetchBookmarkStatus() async {
    DocumentSnapshot documentSnapshot = await db
        .collection("users")
        .doc(user!.uid)
        .collection("bookmarks")
        .doc(widget.news.title)
        .get();
    setState(() {
      _savedToBookmarks = documentSnapshot.exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.news.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: _onPressBookmark,
            iconSize: 32,
            icon: Icon(
                _savedToBookmarks ? Icons.bookmark : Icons.bookmark_border),
            color: Colors.grey.shade400,
          )
        ],
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  widget.news.urlToImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image(
                        image: AssetImage(_placeHolderImage),
                        fit: BoxFit.cover);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.news.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async => await launchUrl(Uri.parse(widget.news.url)),
                child: Text(
                  widget.news.content
                      .replaceAll(RegExp(r"\s\[\+\d+\s+chars\]"), ""),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    widget.news.author.split(",")[0],
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMMM dd, yyyy h:mm a')
                        .format(DateTime.parse(widget.news.publishedAt))
                        .toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Builder(builder: (context) {
                    return IconButton(
                      iconSize: 32,
                      icon: const Icon(Icons.share),
                      color: Colors.blue,
                      onPressed: () => _shareLink(),
                    );
                  }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class NewsPage extends StatelessWidget {
  const NewsPage({
    super.key,
    required this.newsData,
  });

  final List<News> newsData;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: newsData.length,
                itemBuilder: (BuildContext context, int index) {
                  final News item = newsData[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewsContentPage(news: item)));
                    },
                    child: NewsCard(news: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
