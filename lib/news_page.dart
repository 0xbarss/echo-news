import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class NewsCard extends StatelessWidget {
  final Article article;

  const NewsCard({super.key, required this.article});

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
            child: Image.network(article.urlToImage!, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Image(
                      image: AssetImage('assets/images/news-placeholder.jpg'),
                      fit: BoxFit.cover);
                }),
          ),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(article.title!,
                  style: GoogleFonts.roboto(
                      fontSize: 16, fontWeight: FontWeight.w400))),
        ],
      ),
    );
  }
}

class NewsPage extends StatelessWidget {
  final Article article;

  const NewsPage({super.key, required this.article});

  Future<void> _shareLink(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    await Share.share(article.url!,
        subject: article.title!,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title!,
            style:
            GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w400)),
        actions: [
          IconButton(
              onPressed: () {},
              iconSize: 32,
              icon: const Icon(Icons.bookmark),
              color: Colors.grey.shade400)
        ],
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(article.urlToImage!, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Image(
                        image: AssetImage('assets/images/news-placeholder.jpg'),
                        fit: BoxFit.cover);
                  }),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              article.title!,
              style:
              GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            InkWell(
              onTap: () async => await launchUrl(Uri.parse(article.url!)),
              child: Text(
                  article.content!
                      .replaceAll(RegExp(r"\s\[\+\d+\s+chars\]"), ""),
                  style: GoogleFonts.roboto(
                      fontSize: 18, fontWeight: FontWeight.w400)),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: Text(article.author!,
                      style: GoogleFonts.roboto(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          fontWeight: FontWeight.w400)),
                ),
                const Spacer(),
                Expanded(
                  child: Text(
                      DateFormat('MMMM dd, yyyy h:mm a')
                          .format(DateTime.parse(article.publishedAt!))
                          .toString(),
                      style: GoogleFonts.roboto(
                          fontStyle: FontStyle.italic,
                          fontSize: 14,
                          fontWeight: FontWeight.w400)),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Builder(builder: (context) {
                  return IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.share),
                    color: Colors.blue,
                    onPressed: () => _shareLink(context),
                  );
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
