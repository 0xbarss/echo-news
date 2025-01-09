import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

List<News> organizeArticles(List<Article> newsData) {
  return newsData
      .map(
        (article) => News(
          article.author ?? 'Unknown Author',
          article.title ?? 'No Title',
          article.description ?? 'No Description',
          article.url ?? 'No URL',
          article.urlToImage ??
              'https://i0.wp.com/poolpromag.com/wp-content/uploads/2020/02/News-Placeholder.jpg',
          article.publishedAt ?? DateTime.now().toString(),
          article.content ?? '',
        ),
      )
      .where((article) => article.title != '[Removed]')
      .toList();
}

Future<List<News>> getNewsWithSearch(NewsAPI newsAPI, String query,
    {DateTime? fromDate, DateTime? toDate, String? sortBy}) async {
  List<Article> fetchedNewsData = [];
  try {
    fetchedNewsData = await newsAPI.getEverything(
      query: query,
      from: fromDate,
      to: toDate,
      language: 'en',
      sortBy: sortBy,
    );
    return organizeArticles(fetchedNewsData);
  } catch (e) {
    //print("Error $e);
  }
  return [];
}

Future<List<News>> getNewsWithCategory(NewsAPI newsAPI,
    {String category = "general"}) async {
  List<Article> fetchedNewsData = [];
  try {
    fetchedNewsData =
        await newsAPI.getTopHeadlines(country: "us", category: category);
    return organizeArticles(fetchedNewsData);
  } catch (e) {
    //print("Error $e");
  }
  return [];
}

class News {
  final String author,
      title,
      description,
      url,
      urlToImage,
      publishedAt,
      content;

  News(
    this.author,
    this.title,
    this.description,
    this.url,
    this.urlToImage,
    this.publishedAt,
    this.content,
  );

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      json["author"],
      json["title"],
      json["description"],
      json["url"],
      json["urlToImage"],
      json["publishedAt"],
      json["content"],
    );
  }

  static List<News> parseList(dynamic list) {
    if (list == null || list is! List || list.isEmpty) return [];
    return list.map((e) => News.fromJson(e)).toList();
  }

  Map<String, String> toJson() {
    return {
      "author": author,
      "title": title,
      "description": description,
      "url": url,
      "urlToImage": urlToImage,
      "publishedAt": publishedAt,
      "content": content,
    };
  }
}

class NewsCard extends StatelessWidget {
  final News news;
  final String _placeHolderImage = 'assets/images/news-placeholder.jpg';

  const NewsCard({super.key, required this.news});

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
            child: Image.network(
              news.urlToImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image(
                    image: AssetImage(_placeHolderImage), fit: BoxFit.cover);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              news.title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class NewsContentPage extends StatefulWidget {
  final News news;

  const NewsContentPage({super.key, required this.news});

  @override
  State<NewsContentPage> createState() => _NewsContentPageState();
}

class _NewsContentPageState extends State<NewsContentPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final _placeHolderImage = 'assets/images/news-placeholder.jpg';
  bool _savedToBookmarks = false;

  @override
  void initState() {
    super.initState();
    _fetchBookmarkStatus();
  }

  Future<void> _shareLink() async => await Share.share(
        widget.news.url,
        subject: widget.news.title,
      );

  Future<void> _manageBookmark() async {
    if (!_savedToBookmarks) {
      final String bookmarkID = widget.news.title;
      final Map<String, String> article = {
        "author": widget.news.author,
        "title": widget.news.title,
        "description": widget.news.description,
        "url": widget.news.url,
        "urlToImage": widget.news.urlToImage,
        "publishedAt": widget.news.publishedAt,
        "content": widget.news.content,
      };
      await db
          .collection("users")
          .doc(user!.uid)
          .collection("bookmarks")
          .doc(bookmarkID)
          .set(article);
    } else {
      await db
          .collection("users")
          .doc(user!.uid)
          .collection("bookmarks")
          .doc(widget.news.title)
          .delete();
    }
  }

  void _onPressBookmark() {
    _manageBookmark();
    setState(() {
      _savedToBookmarks = !_savedToBookmarks;
    });
  }

  Future<void> _fetchBookmarkStatus() async {
    DocumentSnapshot documentSnapshot = await db
        .collection("users")
        .doc(user!.uid)
        .collection("bookmarks")
        .doc(widget.news.title)
        .get();
    setState(() {
      _savedToBookmarks = documentSnapshot.exists;
    });
  }

  void _navigateToFollowingPage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => FollowingPage(news: widget.news)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.news.title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        actions: [
          IconButton(
            onPressed: _onPressBookmark,
            iconSize: 32,
            icon: Icon(
                _savedToBookmarks ? Icons.bookmark : Icons.bookmark_border),
            color: Colors.grey.shade400,
          )
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
                child: Image.network(
                  widget.news.urlToImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image(
                        image: AssetImage(_placeHolderImage),
                        fit: BoxFit.cover);
                  },
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.news.title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async => await launchUrl(Uri.parse(widget.news.url)),
                child: Text(
                  widget.news.content
                      .replaceAll(RegExp(r"\s\[\+\d+\s+chars\]"), ""),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    widget.news.author.split(",")[0],
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMMM dd, yyyy h:mm a')
                        .format(DateTime.parse(widget.news.publishedAt))
                        .toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.send_outlined),
                    onPressed: _navigateToFollowingPage,
                    color: Colors.blueGrey,
                  ),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.share),
                    color: Colors.blue,
                    onPressed: () => _shareLink(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FollowingPage extends StatefulWidget {
  final News news;

  const FollowingPage({super.key, required this.news});

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

  Future<void> _getFollowedUsers() async {
    DocumentSnapshot documentSnapshot =
        await _db.collection("users").doc(_user!.uid).get();
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
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MessageDetailPage(
                  id: id,
                  news: widget.news,
                )));
  }

  Future<String> _getUsername(String id) async {
    DocumentSnapshot documentSnapshot =
        await _db.collection("users").doc(id).get();
    return documentSnapshot.get("username");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
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
  final News news;

  const MessageDetailPage({super.key, required this.id, required this.news});

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
    _sendNews();
  }

  Future<void> _getUsername() async {
    DocumentSnapshot documentSnapshot =
        await _db.collection("users").doc(widget.id).get();
    setState(() {
      _username = documentSnapshot.get("username");
    });
  }

  Future<void> _fetchHistoricalMessages() async {
    QuerySnapshot receivedMessages = await _db
        .collection("messages")
        .where('sender', isEqualTo: widget.id)
        .where('recipient', isEqualTo: _user!.uid)
        .get();
    QuerySnapshot sentMessages = await _db
        .collection("messages")
        .where('recipient', isEqualTo: widget.id)
        .where('sender', isEqualTo: _user.uid)
        .get();
    List<Map<String, dynamic>> fetchedMessages = [
      ...receivedMessages.docs.map((doc) => doc.data() as Map<String, dynamic>),
      ...sentMessages.docs.map((doc) => doc.data() as Map<String, dynamic>),
    ];
    fetchedMessages
        .sort((m1, m2) => m1["timestamp"]!.compareTo(m2["timestamp"]!));
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

  Future<void> _sendNews() async {
    final DateTime timestamp = DateTime.timestamp();

    final Map<String, dynamic> message = {
      "sender": _user!.uid,
      "message": "",
      "recipient": widget.id,
      "timestamp": timestamp,
      ...widget.news.toJson(),
    };

    setState(() {
      _messages.add(message);
    });
    await _db.collection("messages").add(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
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
                      mainAxisAlignment: isSelf
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Card(
                          color: isSelf ? Colors.blue : Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(12),
                              topRight: const Radius.circular(12),
                              bottomLeft: isSelf
                                  ? const Radius.circular(12)
                                  : Radius.zero,
                              bottomRight: isSelf
                                  ? Radius.zero
                                  : const Radius.circular(12),
                            ),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              message["message"]!,
                              style: const TextStyle(color: Colors.black),
                            ),
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
                  IconButton(
                      onPressed: _sendMessage, icon: const Icon(Icons.send)),
                ],
              ),
            )
          ],
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

  final List<News> newsData;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                itemCount: newsData.length,
                itemBuilder: (BuildContext context, int index) {
                  final News item = newsData[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  NewsContentPage(news: item)));
                    },
                    child: NewsCard(news: item),
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
