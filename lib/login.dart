import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:news_api_flutter_package/model/article.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'news.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = false;

  Future<void> _navigateToHomePage(BuildContext context) async {
    NewsAPI newsAPI = NewsAPIProvider.of(context).newsAPI;
    List<Article> newsData = await getNewsWithCategory(newsAPI);

    if (context.mounted) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(newsData: newsData)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 60,
          ),
          Text("Welcome to EchoNews",
              style:
                  GoogleFonts.lato(fontSize: 24, fontWeight: FontWeight.w800)),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Icon(
              Icons.person_sharp,
              size: 144,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  label: Text("E-mail"),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.visiblePassword,
              obscureText: _obscureText,
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: GestureDetector(
                      onTap: () => setState(() {
                            _obscureText = !_obscureText;
                          }),
                      child: Icon(_obscureText
                          ? Icons.visibility_off
                          : Icons.visibility)),
                  label: const Text("Password"),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  )),
            ),
          ),
          ElevatedButton(
              onPressed: () => _navigateToHomePage(context),
              child: const Text("Login")),
          const SizedBox(
            height: 60,
          ),
          TextButton(onPressed: () {}, child: const Text("Forgot Password?")),
          const SizedBox(
            height: 60,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Doesn't have an account?"),
              TextButton(onPressed: () {}, child: const Text("Sign Up!")),
            ],
          )
        ],
      ),
    );
  }
}
