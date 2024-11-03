import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';

Future<void> main() async {
  const String apiKey = "a194493e5fd94fff814c7eebf34e2f65";

  //NewsAPI newsAPI = NewsAPI(apiKey: apiKey);
  //List<Article> articleList = await newsAPI.getTopHeadlines(country: "us", category: "science");
  //print(articleList[0].content);

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
  List<String> newsData = [];
  int _bottomNavigationBarIndex = 0;

  void _onSelected(index) {
    setState(() {
      _bottomNavigationBarIndex = index;
    });
  }

  void _displayProfilePage() {
    setState(() {

    });
  }

  void _displaySettingsPage() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Echo News'),
        backgroundColor: Colors.red,
        centerTitle: true,
        leading: IconButton(
            onPressed: _displayProfilePage, icon: const Icon(Icons.person_2_sharp)),
        actions: [
          IconButton(onPressed: _displaySettingsPage, icon: const Icon(Icons.settings))
        ],
      ),
      body: Center(
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
          },
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
