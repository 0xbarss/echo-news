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

  void _onPressMessage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const FollowingPage();
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
                  ?.copyWith(fontWeight: FontWeight.bold, color: Colors.black),
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
            onPressed: () => _onPressMessage(context),
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
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
        await _db.collection("users").doc(_user?.uid).get();
    setState(() {
      _usernameController.text = userDoc["username"];
      _emailController.text = _user!.email!;
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
        await _user?.verifyBeforeUpdateEmail(_emailController.text);
      }
      if (_usernameController.text.isNotEmpty) {
        QuerySnapshot querySnapshot = await _db
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
        _db.collection("users")
          .doc(_user!.uid)
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
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
    await _db.collection("users").doc(_user!.uid).update({"isDarkMode": value});
    setState(() {
      _isDarkMode = value;
    });
  }

  Future<void> _removeBookmarks() async {
    QuerySnapshot querySnapshot = await _db
        .collection("users")
        .doc(_user!.uid)
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
    await _db.collection("users").doc(_user!.uid).delete();
    try {
      await _user.delete();
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
                title: const Text("Delete Account"),
                onTap: () => _onPressDeleteAccount(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  Widget _createTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Help Center"),
          centerTitle: true,
        ),
        body: ListView(
          children: [
            _createTitle("Frequently Asked Questions"),
            const HelpCenterItem(
                question: "How do I reset my password?",
                answer:
                    'To reset your password, go to the login screen and tap on "Forgot Password".'),
            const HelpCenterItem(
                question: "How do I update my profile?",
                answer:
                    'You can update your profile from the "Settings" section.'),
            const SizedBox(height: 20),
            _createTitle("Troubleshooting"),
            const HelpCenterItem(
                question: "App is not loading?",
                answer:
                    "Try restarting the app or check your internet connection."),
            const HelpCenterItem(
                question: "The app crashes on launch?",
                answer: "Please clear the app cache or reinstall the app."),
            const SizedBox(height: 20),
            _createTitle("Contact Us"),
            const HelpCenterItem(
                question: "Need further assistance?",
                answer: "Email us at baris.ozdemir@std.izmirekonomi.edu.tr"),
          ],
        ));
  }
}

class HelpCenterItem extends StatefulWidget {
  final String question;
  final String answer;

  const HelpCenterItem(
      {super.key, required this.question, required this.answer});

  @override
  State<HelpCenterItem> createState() => _HelpCenterItemState();
}

class _HelpCenterItemState extends State<HelpCenterItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        widget.question,
        style: const TextStyle(fontStyle: FontStyle.italic),
      ),
      subtitle: _isExpanded ? Text(widget.answer) : null,
      trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
      onTap: () => setState(() {
        _isExpanded = !_isExpanded;
      }),
    );
  }
}

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final List<String> _followedIds = [];
  final List<String> _followedUsernames = [];

  @override
  void initState() {
    super.initState();
    _getFollowedUsers();
  }

  void _onPressAddPerson() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPersonPage(
                followedIds: _followedIds, managePerson: _managePerson)));
  }

  Future<void> _managePerson(String id) async {
    final String username = await _getUsername(id);
    if (_followedIds.contains(id)) {
      await _db.collection("users")
          .doc(_user!.uid)
          .update({"following": FieldValue.arrayRemove([id])});
      setState(() {
        _followedIds.remove(id);
        _followedUsernames.remove(username);
      });
    } else {
      await _db
          .collection("users")
          .doc(_user!.uid)
          .update({"following": FieldValue.arrayUnion([id])});
      setState(() {
        _followedIds.add(id);
        _followedUsernames.add(username);
      });
    }
  }

  Future<void> _getFollowedUsers() async {
    DocumentSnapshot documentSnapshot = await _db
        .collection("users")
        .doc(_user!.uid)
        .get();
    List<String> fetchedFollowedIds = [];
    List<String> fetchedFollowedUsernames = [];
    for (var id in documentSnapshot.get("following") as List<dynamic>) {
      fetchedFollowedIds.add(id);
      fetchedFollowedUsernames.add(await _getUsername(id));
    }
    setState(() {
      _followedIds.addAll(fetchedFollowedIds);
      _followedUsernames.addAll(fetchedFollowedUsernames);
    });
  }

  void _onPressMessage(String id) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MessageDetailPage(id: id)));
  }

  Future<String> _getUsername(String id) async {
    DocumentSnapshot documentSnapshot = await _db.collection("users").doc(id).get();
    return documentSnapshot.get("username");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _onPressAddPerson,
            icon: const Icon(Icons.person_add),
          )
        ],
      ),
      body: ListView.builder(
          itemCount: _followedIds.length,
          itemBuilder: (BuildContext context, int index) {
            final String id = _followedIds[index];
            final String username = _followedUsernames[index];
            return Card(
              child: ListTile(
                title: Text(username),
                leading: const Icon(Icons.person),
                trailing: IconButton(
                  icon: const Icon(Icons.message_sharp),
                  onPressed: () => _onPressMessage(id),
                ),
              ),
            );
          }),
    );
  }
}

class MessageDetailPage extends StatefulWidget {
  final String id;

  const MessageDetailPage({super.key, required this.id});

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  String _username = "";

  @override
  void initState() {
    super.initState();
    _getUsername();
    _fetchHistoricalMessages();
  }

  Future<void> _getUsername() async {
    DocumentSnapshot documentSnapshot = await _db.collection("users").doc(widget.id).get();
    setState(() {
      _username = documentSnapshot.get("username");
    });
  }

  Future<void> _fetchHistoricalMessages() async {
    QuerySnapshot receivedMessages = await _db.collection("messages").where('sender', isEqualTo: widget.id).where('recipient', isEqualTo: _user!.uid).get();
    QuerySnapshot sentMessages = await _db.collection("messages").where('recipient', isEqualTo: widget.id).where('sender', isEqualTo: _user.uid).get();
    List<Map<String, dynamic>> fetchedMessages = [
      ...receivedMessages.docs.map((doc) => doc.data() as Map<String, dynamic>),
      ...sentMessages.docs.map((doc) => doc.data() as Map<String, dynamic>),
    ];
    fetchedMessages.sort((m1, m2) => m1["timestamp"]!.compareTo(m2["timestamp"]!));
    setState(() {
      _messages.clear();
      _messages.addAll(fetchedMessages);
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final DateTime timestamp = DateTime.timestamp();

    final Map<String, dynamic> message = {
      "sender": _user!.uid,
      "recipient": widget.id,
      "message": _messageController.text,
      "timestamp": timestamp
    };

    setState(() {
      _messages.add(message);
    });
    await _db.collection("messages").add(message);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_username, style: const TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchHistoricalMessages,
        child: Column(
          children: [
            Flexible(
              child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _messages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> message = _messages[index];
                    final bool isSelf = widget.id != message["sender"];
                    if (message["message"].isEmpty) {
                      final News news = News.fromJson(message);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      NewsContentPage(news: news)));
                        },
                        child: NewsCard(news: news),
                      );
                    }
                    return Row(
                      mainAxisAlignment: isSelf ? MainAxisAlignment.end: MainAxisAlignment.start,
                      children: [
                        Card(
                          color: isSelf ? Colors.blue: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft:
                                  isSelf ? const Radius.circular(12) : Radius.zero,
                              bottomRight:
                                  isSelf ? Radius.zero : const Radius.circular(12),
                            ),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(message["message"]!, style: const TextStyle(color: Colors.black),),
                          ),
                        )
                      ],
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      showCursor: true,
                      controller: _messageController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AddPersonPage extends StatefulWidget {
  final List<String> followedIds;
  final Function(String) managePerson;

  const AddPersonPage(
      {super.key, required this.followedIds, required this.managePerson});

  @override
  State<AddPersonPage> createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final List<String> _ids = [];
  final List<String> _usernames = [];
  final TextEditingController _usernameController = TextEditingController();

  Future<void> _fetchAllUsernames(String query) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final FirebaseFirestore db = FirebaseFirestore.instance;

    QuerySnapshot allUsers = await db
        .collection("users")
        .where("username", isGreaterThanOrEqualTo: query)
        .get();

    var fetchedUsernames = allUsers.docs
        .where((doc) => doc["username"] != user?.displayName)
        .map((doc) => doc["username"] as String);
    var fetchedIds = allUsers.docs.
        where((doc) => doc["username"] != user?.displayName)
        .map((doc) => doc.id);

    setState(() {
      _ids.clear();
      _usernames.clear();
      _ids.addAll(fetchedIds);
      _usernames.addAll(fetchedUsernames);
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Person", style: TextStyle(fontWeight: FontWeight.bold),),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              showCursor: true,
              controller: _usernameController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                suffixIcon: Icon(Icons.arrow_back_sharp),
                label: Text("Enter a username"),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              onSubmitted: (value) => _fetchAllUsernames(value),
            ),
          ),
          Flexible(
            child: ListView.builder(
                itemCount: _usernames.length,
                itemBuilder: (BuildContext context, int index) {
                  final String id = _ids[index];
                  final String username = _usernames[index];
                  return Person(
                    id: id,
                    username: username,
                    isFollowed: widget.followedIds.contains(id),
                    managePerson: widget.managePerson,
                  );
                }),
          )
        ],
      ),
    );
  }
}

class Person extends StatefulWidget {
  const Person({
    super.key,
    required this.id,
    required this.username,
    required this.isFollowed,
    required this.managePerson,
  });

  final String id;
  final String username;
  final bool isFollowed;
  final Function(String) managePerson;

  @override
  State<Person> createState() => _PersonState();
}

class _PersonState extends State<Person> {
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isFollowed = widget.isFollowed;
    });
  }

  void _onPressFollow() {
    widget.managePerson(widget.id);
    setState(() {
      _isFollowed = !_isFollowed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(widget.username),
        trailing: IconButton(
          icon: Icon(_isFollowed ? Icons.check : Icons.add),
          onPressed: _onPressFollow,
        ),
      ),
    );
  }
}
