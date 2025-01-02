import 'package:flutter/material.dart';
import 'package:news_api_flutter_package/news_api_flutter_package.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'theme_provider.dart';
import 'news_api_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(NewsAPIProvider(NewsAPI(apiKey: "a194493e5fd94fff814c7eebf34e2f65"),
      child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeData _currentTheme = ThemeData.light();

  void _updateTheme(ThemeData newTheme) {
    setState(() {
      _currentTheme = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      themeData: _currentTheme,
      updateTheme: _updateTheme,
      child: MaterialApp(
        title: 'Echo News',
        theme: _currentTheme,
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
