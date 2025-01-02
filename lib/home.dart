import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'news.dart';
import 'search.dart';
import 'categories.dart';
import 'bookmarks.dart';
import 'login.dart';
import 'theme_provider.dart';
import 'news_api_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavigationBarIndex = 0;
  final List<News> _newsData = [];
  final List<Widget> _pages = [];
  final String _logoPath = 'assets/images/logo.png';

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const Center(child: CircularProgressIndicator()),
      const SearchPage(),
      const CategoriesPage(),
      const BookmarksPage(),
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getInitialSettings(context);
      _getNewsData(context);
    });
  }

  Future<void> _getInitialSettings(BuildContext context) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final DocumentSnapshot documentSnapshot =
        await db.collection("users").doc(user!.uid).get();
    final data = documentSnapshot.data() as Map<String, dynamic>;

    if (context.mounted) {
      ThemeProvider.of(context).updateTheme(
          data["isDarkMode"] ? ThemeData.dark() : ThemeData.light());
    }
  }

  Future<void> _getNewsData(BuildContext context) async {
    NewsAPI newsAPI = NewsAPIProvider.of(context).newsAPI;
    List<News> fetchedNewsData = await getNewsWithCategory(newsAPI);

    if (context.mounted) {
      setState(() {
        _newsData.addAll(fetchedNewsData);
        _pages[0] = NewsPage(newsData: _newsData);
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
              _logoPath,
              height: 30,
            ),
            Text(
              'Echo News',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        flexibleSpace: const FlexibleSpaceBar(
          background: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red, Colors.orange],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => _onPressProfile(context),
          icon: const Icon(
            Icons.person_2_sharp,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => {},
            icon: const Icon(
              Icons.message,
              color: Colors.black,
            ),
          ),
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
  final String _logoPath = 'assets/images/logo.png';

  void _onPressMyAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void _navigateToSettingsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ),
    );
  }

  void _navigateToHelpCenterPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HelpCenterPage(),
      ),
    );
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
        title: Text(
          "Profile",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              child: Image.asset(_logoPath),
            ),
            const SizedBox(height: 40),
            ProfilePageCard(
              title: "My Account",
              leadingIcon: const Icon(Icons.person_outline_outlined),
              func: _onPressMyAccount,
            ),
            const SizedBox(height: 20),
            ProfilePageCard(
              title: "Settings",
              leadingIcon: const Icon(Icons.settings_outlined),
              func: () => _navigateToSettingsPage(context),
            ),
            const SizedBox(height: 20),
            ProfilePageCard(
              title: "Help Center",
              leadingIcon: const Icon(Icons.help_outline_outlined),
              func: () => _navigateToHelpCenterPage(context),
            ),
            const SizedBox(height: 20),
            ProfilePageCard(
              title: "Sign Out",
              leadingIcon: const Icon(Icons.logout),
              func: () => _onPressSignOut(context),
            ),
          ],
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
  final TextEditingController _usernameController =
      TextEditingController(text: "");
  final TextEditingController _emailController =
      TextEditingController(text: "");
  final String _logoPath = 'assets/images/logo.png';
  bool _isNotCompleted = true;

  @override
  void initState() {
    super.initState();
    _getProfileInformation();
  }

  Future<void> _getProfileInformation() async {
    final DocumentSnapshot userDoc =
        await db.collection("users").doc(user?.uid).get();
    setState(() {
      _usernameController.text = userDoc["username"];
      _emailController.text = user!.email!;
    });
    _isNotCompleted = false;
  }

  void _showUpdateStatus(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _updateData(BuildContext context) async {
    try {
      if (_emailController.text.isNotEmpty) {
        await user?.verifyBeforeUpdateEmail(_emailController.text);
      }
      if (_usernameController.text.isNotEmpty) {
        QuerySnapshot querySnapshot = await db
            .collection("users")
            .where("username", isEqualTo: _usernameController.text)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          if (context.mounted) {
            _showUpdateStatus(context,
                message: "This username is already in use");
          }
          return;
        }
        db
            .collection("users")
            .doc(user!.uid)
            .update({"username": _usernameController.text});
        if (context.mounted) {
          _showUpdateStatus(context, message: "Username changed successfully");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        if (context.mounted) {
          _showUpdateStatus(context, message: "This email is already in use");
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isNotCompleted) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 70,
              child: Image.asset(_logoPath),
            ),
            const SizedBox(height: 40),
            EditProfilePageCard(
              title: "username",
              prefixIcon: const Icon(Icons.person_2_sharp),
              controller: _usernameController,
            ),
            const SizedBox(height: 20),
            EditProfilePageCard(
              title: "e-mail",
              prefixIcon: const Icon(Icons.email),
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _updateData(context),
              child: const Text("Update"),
            )
          ],
        ),
      ),
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
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 15,
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)))),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _getInitialSettings(context));
  }

  void _getInitialSettings(BuildContext context) {
    setState(() {
      _isDarkMode = ThemeProvider.of(context).themeData == ThemeData.dark();
    });
  }

  Future<void> _onPressDarkMode(bool value) async {
    ThemeProvider.of(context)
        .updateTheme(_isDarkMode ? ThemeData.light() : ThemeData.dark());
    await db.collection("users").doc(user!.uid).update({"isDarkMode": value});
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _removeBookmarks() async {
    QuerySnapshot querySnapshot = await db
        .collection("users")
        .doc(user!.uid)
        .collection("bookmarks")
        .get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _onPressRemoveBookmarks(BuildContext context) async {
    bool? isConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Remove Bookmarks"),
            content:
                const Text("Are you sure you want to remove all bookmarks?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          );
        });

    if (isConfirmed == null || !isConfirmed) return;
    _removeBookmarks();
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false);
  }

  Future<void> _deleteAccount() async {
    await db.collection("users").doc(user!.uid).delete();
    try {
      await user?.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Do nothing
      }
    }
  }

  Future<void> _onPressDeleteAccount(BuildContext context) async {
    bool? isConfirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Delete Account"),
            content:
                const Text("Are you sure you want to delete your account?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          );
        });

    if (isConfirmed == null || !isConfirmed) return;

    _deleteAccount();
    if (context.mounted) {
      _navigateToLoginPage(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text("Dark Mode"),
                trailing: Switch(
                    value: _isDarkMode,
                    onChanged: (value) => _onPressDarkMode(value)),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bookmarks),
                title: const Text("Remove Bookmarks"),
                onTap: () => _onPressRemoveBookmarks(context),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text("Remove Account"),
                onTap: () => _onPressDeleteAccount(context),
              ),
            ),
          ],
        ),
      ),
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
      appBar: AppBar(),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
