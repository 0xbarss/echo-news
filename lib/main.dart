import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'news.dart';
import 'login.dart';

void main() {
  runApp(NewsAPIProvider(NewsAPI(apiKey: "a194493e5fd94fff814c7eebf34e2f65"),
      child: const MyApp()));
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

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}
