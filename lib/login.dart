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
  bool _obscureText = true;
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void showLoginDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Login Failed"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"))
              ],
            ));
  }

  Future<void> _onPressForgotPassword(BuildContext context) async {
    if (emailAddressController.text.isEmpty) {
      showLoginDialog(context, "Please enter an email");
    }

    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailAddressController.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        if (context.mounted) {
          showLoginDialog(context, "Please enter a valid email");
        }
      }
      return;
    }

    if (context.mounted) {
      showLoginDialog(context, "Password reset link sent successfully.");
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
          showLoginDialog(context, 'No user found for that email.');
        } else if (e.code == 'network-request-failed') {
          showLoginDialog(context, 'There is no internet connection!');
        } else if (e.code == 'invalid-credential') {
          showLoginDialog(context, "Wrong e-mail or password provided.");
        } else {
          showLoginDialog(context, e.code);
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 60,
          ),
          Text("Welcome to EchoNews",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Icon(
              Icons.person_sharp,
              size: 144,
            ),
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
    );
  }
}
