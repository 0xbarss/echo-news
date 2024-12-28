import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'register.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final String logoPath = 'assets/images/logo.png';
  bool _obscureText = true;

  void showLoginStatus(BuildContext context, {required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    ));
  }

  Future<void> _onPressForgotPassword(BuildContext context) async {
    if (emailAddressController.text.isEmpty) {
      showLoginStatus(context, message: "Please enter an email.");
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailAddressController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        if (context.mounted) {
          showLoginStatus(context, message: "Please enter a valid email.");
        }
      }
      return;
    }

    if (context.mounted) {
      showLoginStatus(context, message: "Password reset link sent successfully.");
    }
  }

  void _navigateToRegisterPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const RegisterPage()));
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const HomePage(
                  newsData: [],
                )));
  }

  Future<void> _onPressLogin(BuildContext context) async {
    if (emailAddressController.text.isEmpty || passwordController.text.isEmpty) {
      return;
    }

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddressController.text,
          password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-not-found') {
          showLoginStatus(context, message: 'No user found for that email.');
        } else if (e.code == 'network-request-failed') {
          showLoginStatus(context, message: 'There is no internet connection!');
        } else if (e.code == 'invalid-credential') {
          showLoginStatus(context, message: "Wrong e-mail or password provided.");
        }
      }
      return;
    }

    if (context.mounted) {
      _navigateToHomePage(context);
    }
  }

  @override
  void dispose() {
    emailAddressController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0x102B394D)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(
              height: 60,
            ),
            Text("Welcome to EchoNews",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2B394D))),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Image.asset(logoPath, height: 250,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
              child: TextField(
                textAlign: TextAlign.center,
                controller: emailAddressController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email),
                    label: const Text("E-mail"),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12),
              child: TextField(
                textAlign: TextAlign.center,
                controller: passwordController,
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    )),
              ),
            ),
            ElevatedButton(
              style: const ButtonStyle(backgroundColor: WidgetStatePropertyAll(Colors.white)),
                onPressed: () => _onPressLogin(context),
                child: const Text("Login")),
            const SizedBox(
              height: 60,
            ),
            TextButton(
                onPressed: () => _onPressForgotPassword(context),
                child: const Text("Forgot Password?")),
            const SizedBox(
              height: 60,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Doesn't have an account?"),
                TextButton(
                    onPressed: () => _navigateToRegisterPage(context),
                    child: const Text("Sign Up!")),
              ],
            )
          ],
        ),
      ),
    );
  }
}
