import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'news_page.dart';
import 'categories.dart';
import 'search.dart';

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
  final NewsAPI newsAPI = NewsAPI(apiKey: "a194493e5fd94fff814c7eebf34e2f65");
  List<Article> newsData = [];
  int _bottomNavigationBarIndex = 0;

  void _onSelected(index) {
    setState(() {
      _bottomNavigationBarIndex = index;
    });

    if (_bottomNavigationBarIndex == 1) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchPage(
                    newsAPI: newsAPI,
                    onSearch: (List<Article> searchedNewsData) {
                      setState(() {
                        newsData = searchedNewsData;
                        _bottomNavigationBarIndex = 0;
                      });
                    },
                  )));
    } else if (_bottomNavigationBarIndex == 2) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => CategoriesPage(
                    newsAPI: newsAPI,
                    onCategorySelected: (List<Article> selectedNewsData) {
                      setState(() {
                        newsData = selectedNewsData;
                        _bottomNavigationBarIndex = 0;
                      });
                    },
                  )));
    }
  }

  Future<void> updateNewsData(NewsAPI newsAPI) async {
    List<Article> fetchedData = await getNewsWithCategory(newsAPI);
    setState(() {
      newsData = fetchedData;
    });
  }

  @override
  void initState() {
    super.initState();
    updateNewsData(newsAPI);
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
      body: HomePage(newsData: newsData),
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
