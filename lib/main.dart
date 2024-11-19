import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:google_fonts/google_fonts.dart';
import 'news_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Echo News',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Home Page'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String apiKey = "a194493e5fd94fff814c7eebf34e2f65";
  late NewsAPI newsAPI;
  int _bottomNavigationBarIndex = 0;
  List<Article> newsData = [];

  void _onSelected(index) {
    setState(() {
      _bottomNavigationBarIndex = index;
    });
  }

  Future<void> _getTopHeadLines(NewsAPI newsAPI) async {
    try {
      List<Article> fetchedNewsData =
          await newsAPI.getTopHeadlines(country: "us", category: "general");
      setState(() {
        newsData = fetchedNewsData
            .map((article) => Article(
                article.source,
                article.author ?? 'Unknown Author',
                article.title ?? 'No Title',
                article.description ?? 'No Description',
                article.url ?? 'No URL',
                article.urlToImage ??
                    'https://i0.wp.com/poolpromag.com/wp-content/uploads/2020/02/News-Placeholder.jpg',
                article.publishedAt ?? 'Unknown Date',
                article.content ?? 'No Content'))
            .where((article) => article.title != '[Removed]')
            .toList();
      });
    } catch (e) {
      print("Error $e");
    }
  }

  @override
  void initState() {
    super.initState();
    NewsAPI newsAPI = NewsAPI(apiKey: apiKey);
    _getTopHeadLines(newsAPI);
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
        leading: IconButton(
            onPressed: () => {}, icon: const Icon(Icons.person_2_sharp)),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
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
                              builder: (context) => NewsPage(article: item)));
                    },
                    child: NewsCard(article: item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmark), label: 'Bookmarks')
        ],
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        currentIndex: _bottomNavigationBarIndex,
        onTap: _onSelected,
        showUnselectedLabels: true,
      ),
    );
  }
}