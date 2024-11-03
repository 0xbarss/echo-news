import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

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
      List<Article> fetchedNewsData = await newsAPI.getTopHeadlines(
          country: "us", category: "science");
      setState(() {
        newsData = fetchedNewsData.where((article) => article.title != "[Removed]").toList();
      });
    }
    catch (e) {
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
        title: const Text('Echo News'),
        backgroundColor: Colors.red,
        centerTitle: true,
        leading: IconButton(
            onPressed: () => {}, icon: const Icon(Icons.person_2_sharp)),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: newsData.length,
                itemBuilder: (BuildContext context, int index) {
                  final Article item = newsData[index];
                  return NewsCard(title: item.title ?? 'No Title',
                      content: item.content ?? 'No Content',
                      imageURL: item.urlToImage ?? 'No URL');
                },
              ),
            ],
          ),
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
        unselectedItemColor: Colors.blue,
        currentIndex: _bottomNavigationBarIndex,
        onTap: _onSelected,
        showUnselectedLabels: true,
      ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String title;
  final String content;
  final String imageURL;

  const NewsCard({
    super.key,
    required this.title,
    required this.content,
    required this.imageURL,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageURL, width:400, height:200, errorBuilder: (context, object, stackTrace) {
            return Container(color: Colors.grey, width: 400, height: 200, child: const Center(child: Text("No Image")));
          }),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(title))
        ],
      ),
    );
  }
}