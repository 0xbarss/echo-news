import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'news.dart';
import 'search.dart';
import 'categories.dart';
import 'bookmarks.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final List<Article> newsData;

  const HomePage({super.key, required this.newsData});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavigationBarIndex = 0;
  List<Article> newsData = [];
  final List<Widget> _pages = [];
  bool _isNewsFetched = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isNewsFetched) {
      getNewsData();
      _isNewsFetched = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const Center(child: CircularProgressIndicator()),
      const SearchPage(),
      CategoriesPage(),
      const BookmarksPage()
    ]);
  }

  Future<void> getNewsData() async {
    NewsAPI newsAPI = NewsAPIProvider.of(context).newsAPI;
    List<Article> fetchedNewsData = await getNewsWithCategory(newsAPI);

    if (context.mounted) {
      setState(() {
        newsData.addAll(fetchedNewsData);
        _pages[0] = NewsPage(newsData: newsData);
      });
    }
  }

  void _onSelected(index) {
    setState(() {
      _bottomNavigationBarIndex = index;
    });
  }

  void _onPressProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ProfilePage();
    }));
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
            onPressed: () => _onPressProfile(context),
            icon: const Icon(Icons.person_2_sharp)),
        actions: [
          IconButton(onPressed: () => {}, icon: const Icon(Icons.settings))
        ],
      ),
      body: _pages[_bottomNavigationBarIndex],
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late Map<String, String> userInformation;

  @override
  void initState() {
    super.initState();
    getProfileInformation();
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  Future<void> _onPressSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      _navigateToLoginPage(context);
    }
  }

  Future<void> getProfileInformation() async {
    final DocumentSnapshot userDoc =
        await db.collection("users").doc(user?.uid).get();
    userInformation = {
      "username": userDoc["username"],
      "e-mail": userDoc["e-mail"],
      "password": userDoc["password"]
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DecoratedBox(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.orange, Colors.red],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter)),
        child: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    const CircleAvatar(
                        radius: 70, backgroundColor: Colors.white),
                    Positioned(
                        bottom: 10,
                        right: 0,
                        child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black,
                            )))
                  ],
                ),
              ),
              if (userInformation != null) ProfilePageCard(title: "Username", userInformation: userInformation["username"]!, icon: Icons.person,),
              if (userInformation != null) ProfilePageCard(title: "E-Mail", userInformation: userInformation["e-mail"]!, icon: Icons.email,),
              if (userInformation != null) ProfilePageCard(title: "Password", userInformation: userInformation["password"]!, icon: Icons.lock,),
              ElevatedButton(onPressed: () {}, child: const Text("Sign Out")),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfilePageCard extends StatelessWidget {
  const ProfilePageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.userInformation,
  });

  final String title;
  final IconData icon;
  final String userInformation;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(userInformation),
      ),
    );
  }
}
