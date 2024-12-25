import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      return const ProfilePage();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Echo News',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
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
          IconButton(
              onPressed: () => {},
              icon: const Icon(
                Icons.settings,
                color: Colors.black,
              ))
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
  Map<String, String> userInformation = {};

  @override
  void initState() {
    getProfileInformation();
    super.initState();
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
    userInformation.addAll({
      "username": userDoc["username"],
      "e-mail": userDoc["e-mail"],
      "password": userDoc["password"]
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Profile",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Center(
          child: Column(
            children: [
              Stack(
                children: [
                  const CircleAvatar(radius: 70, backgroundColor: Colors.white),
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
              const SizedBox(
                height: 40,
              ),
              ProfilePageCard(
                  title: "My Account",
                  icon: Icons.person_outline_outlined,
                  func: () => {}),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Notifications",
                  icon: Icons.notifications_none_outlined,
                  func: () => {}),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Settings",
                  icon: Icons.settings_outlined,
                  func: () => {}),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Help Center",
                  icon: Icons.help_outline_outlined,
                  func: () => {}),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Sign Out",
                  icon: Icons.logout,
                  func: () => _onPressSignOut(context)),
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
    required this.title,
    required this.icon,
    required this.func,
  });

  final String title;
  final IconData icon;
  final GestureTapCallback func;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: func,
      ),
    );
  }
}
