import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final String logoPath = 'assets/images/logo.png';

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              logoPath,
              height: 30,
            ),
            Text('Echo News',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
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
  final String logoPath = 'assets/images/logo.png';

  @override
  void initState() {
    super.initState();
  }

  void _onPressMyAccount() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const EditProfilePage()));
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _navigateToNotificationsPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const NotificationsPage()));
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SettingsPage()));
  }

  void _navigateToHelpCenterPage(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const HelpCenterPage()));
  }

  Future<void> _onPressSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      _navigateToLoginPage(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x90E9DACC),
        title: Text(
          "Profile",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0x90E9DACC)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                child: Image.asset(logoPath),
              ),
              const SizedBox(
                height: 40,
              ),
              ProfilePageCard(
                  title: "My Account",
                  leadingIcon: const Icon(Icons.person_outline_outlined),
                  func: _onPressMyAccount),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Notifications",
                  leadingIcon: const Icon(Icons.notifications_none_outlined),
                  func: () => _navigateToNotificationsPage(context)),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Settings",
                  leadingIcon: const Icon(Icons.settings_outlined),
                  func: () => _navigateToSettingsPage(context)),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Help Center",
                  leadingIcon: const Icon(Icons.help_outline_outlined),
                  func: () => _navigateToHelpCenterPage(context)),
              const SizedBox(
                height: 20,
              ),
              ProfilePageCard(
                  title: "Sign Out",
                  leadingIcon: const Icon(Icons.logout),
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
    required this.leadingIcon,
    required this.func,
  });

  final String title;
  final Widget leadingIcon;
  final GestureTapCallback func;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        leading: leadingIcon,
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: func,
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final TextEditingController usernameController = TextEditingController(text: "");
  final TextEditingController emailController = TextEditingController(text: "");
  bool _isNotCompleted = true;
  final String logoPath = 'assets/images/logo.png';

  Future<void> getProfileInformation() async {
    final DocumentSnapshot userDoc =
        await db.collection("users").doc(user?.uid).get();
    setState(() {
      usernameController.text = userDoc["username"];
      emailController.text = user!.email!;
    });
    _isNotCompleted = false;
  }

  @override
  void initState() {
    super.initState();
    getProfileInformation();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void showUpdateStatus(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> updateData(BuildContext context) async {
    try {
      if (emailController.text.isNotEmpty) {
        await user?.verifyBeforeUpdateEmail(emailController.text);
      }
      if (usernameController.text.isNotEmpty) {
        QuerySnapshot querySnapshot = await db
            .collection("users")
            .where("username", isEqualTo: usernameController.text)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          if (context.mounted) {
            showUpdateStatus(context,
                message: "This username is already in use");
          }
          return;
        }
        db.collection("users").doc(user!.uid).update({"username": usernameController.text});
        if (context.mounted) {
          showUpdateStatus(context, message: "Username changed successfully");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (context.mounted) {
          showUpdateStatus(context, message: "This email is already in use");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isNotCompleted) {
      return const Scaffold(
          body: DecoratedBox(
              decoration: BoxDecoration(color: Color(0x90E9DACC)),
              child: Center(child: CircularProgressIndicator())));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x90E9DACC),
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: DecoratedBox(
          decoration: const BoxDecoration(color: Color(0x90E9DACC)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 70,
                  child: Image.asset(logoPath),
                ),
                const SizedBox(
                  height: 40,
                ),
                EditProfilePageCard(
                  title: "username",
                  prefixIcon: const Icon(Icons.person_2_sharp),
                  controller: usernameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                EditProfilePageCard(
                  title: "e-mail",
                  prefixIcon: const Icon(Icons.email),
                  controller: emailController,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    onPressed: () => updateData(context), child: const Text("Update"))
              ],
            ),
          )),
    );
  }
}

class EditProfilePageCard extends StatefulWidget {
  const EditProfilePageCard({
    super.key,
    required this.title,
    required this.prefixIcon,
    required this.controller,
  });

  final String title;
  final Widget prefixIcon;
  final TextEditingController controller;

  @override
  State<EditProfilePageCard> createState() => _EditProfilePageCardState();
}

class _EditProfilePageCardState extends State<EditProfilePageCard> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      showCursor: true,
      controller: widget.controller,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
          prefixIcon: widget.prefixIcon,
          suffixIcon: const Icon(Icons.edit),
          labelText: toBeginningOfSentenceCase(widget.title),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)))),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0x90E9DACC),
      ),
      body: const DecoratedBox(
          decoration: BoxDecoration(color: Color(0x90E9DACC)),
          child: Center(child: CircularProgressIndicator())),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0x90E9DACC)),
      body: const DecoratedBox(
          decoration: BoxDecoration(color: Color(0x90E9DACC)),
          child: Center(child: CircularProgressIndicator())),
    );
  }
}

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0x90E9DACC)),
      body: const DecoratedBox(
          decoration: BoxDecoration(color: Color(0x90E9DACC)),
          child: Center(child: CircularProgressIndicator())),
    );
  }
}
