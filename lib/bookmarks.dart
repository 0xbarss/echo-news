import 'package:echo_news/news.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final List<News> bookmarks = [];
  bool bookmarksFetched = false;

  Future<void> fetchBookmarks() async {
    QuerySnapshot querySnapshot = await db
        .collection("users")
        .doc(user!.uid)
        .collection("bookmarks")
        .get();
    List<News> fetchedBookmarks = [];
    for (var document in querySnapshot.docs) {
      var data = document.data() as Map<String, dynamic>;
      fetchedBookmarks.add(News.fromJson(data));
    }
    setState(() {
      bookmarks.clear();
      bookmarks.addAll(fetchedBookmarks);
      bookmarksFetched = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    if (!bookmarksFetched) {
      return const Center(child: CircularProgressIndicator());
    }
    if (bookmarks.isEmpty) {
      return DecoratedBox(
        decoration: const BoxDecoration(color: Color(0x90E9DACC)),
        child: RefreshIndicator(
          onRefresh: fetchBookmarks,
          child: const Center(
            child: Text("No bookmarks found!"),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: fetchBookmarks,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0x90E9DACC)),
        child: NewsPage(newsData: bookmarks),
      ),
    );
  }
}
