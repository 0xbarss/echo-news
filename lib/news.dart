import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

List<Article> organizeArticles(List<Article> newsData) {
  return newsData
      .map((article) => Article(
          article.source,
          article.author ?? 'Unknown Author',
          article.title ?? 'No Title',
          article.description ?? 'No Description',
          article.url ?? 'No URL',
          article.urlToImage ??
              'https://i0.wp.com/poolpromag.com/wp-content/uploads/2020/02/News-Placeholder.jpg',
          article.publishedAt ?? DateTime.now().toString(),
          article.content ?? ''))
      .where((article) => article.title != '[Removed]')
      .toList();
}

Future<List<Article>> getNewsWithSearch(NewsAPI newsAPI, String query,
    {DateTime? fromDate, DateTime? toDate, String? sortBy}) async {
  List<Article> fetchedNewsData = [];
  try {
    fetchedNewsData = await newsAPI.getEverything(
        query: query,
        from: fromDate,
        to: toDate,
        language: 'en',
        sortBy: sortBy);
    fetchedNewsData = organizeArticles(fetchedNewsData);
  } catch (e) {
    //print("Error $e);
  }
  return fetchedNewsData;
}

Future<List<Article>> getNewsWithCategory(NewsAPI newsAPI,
    {String category = "general"}) async {
  List<Article> fetchedNewsData = [];
  try {
    fetchedNewsData =
        await newsAPI.getTopHeadlines(country: "us", category: category);
    fetchedNewsData = organizeArticles(fetchedNewsData);
  } catch (e) {
    //print("Error $e");
  }
  return fetchedNewsData;
}

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

class NewsCard extends StatelessWidget {
  final Article article;
  final String placeHolderImage = 'assets/images/news-placeholder.jpg';

  const NewsCard({super.key, required this.article});

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
            child: Image.network(article.urlToImage!, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
              return Image(
                  image: AssetImage(placeHolderImage), fit: BoxFit.cover);
            }),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(article.title!,
                  style: Theme.of(context).textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

class NewsContentPage extends StatelessWidget {
  final Article article;
  final placeHolderImage = 'assets/images/news-placeholder.jpg';

  const NewsContentPage({super.key, required this.article});

  Future<void> _shareLink() async => await Share.share(
        article.url!,
        subject: article.title!,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title!,
            style: Theme.of(context).textTheme.headlineSmall),
        actions: [
          IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: const Icon(Icons.bookmark),
              color: Colors.grey.shade400)
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
                child: Image.network(article.urlToImage!, fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                  return Image(
                      image: AssetImage(placeHolderImage), fit: BoxFit.cover);
                }),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                article.title!,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () async => await launchUrl(Uri.parse(article.url!)),
                child: Text(
                    article.content!
                        .replaceAll(RegExp(r"\s\[\+\d+\s+chars\]"), ""),
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(article.author!.split(",")[0],
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic)),
                  const Spacer(),
                  Text(
                      DateFormat('MMMM dd, yyyy h:mm a')
                          .format(DateTime.parse(article.publishedAt!))
                          .toString(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontStyle: FontStyle.italic))
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

  final List<Article> newsData;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0x90E9DACC),
      child: Center(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: newsData.length,
                itemBuilder: (BuildContext context, int index) {
                  final Article item = newsData[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewsContentPage(article: item)));
                    },
                    child: NewsCard(article: item),
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
