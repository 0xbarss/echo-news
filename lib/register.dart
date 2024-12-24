import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = false;

  void showRegisterDialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Register Failed"),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Close"))
              ],
            ));
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.pop(context);
  }

  Future<void> _onPressRegister(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) return;

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'network-request-failed') {
          showRegisterDialog(context, "There is no internet connection!");
        } else if (e.code == 'weak-password') {
          showRegisterDialog(context, "Please enter a stronger password");
        } else if (e.code == 'email-already-in-use') {
          showRegisterDialog(context, "This email is already in use");
        }
      }
      return;
    }

    if (context.mounted) {
      _navigateToLoginPage(context);
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
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: const InputDecoration(
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
              controller: passwordController,
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
              onPressed: () => _onPressRegister(context),
              child: const Text("Register")),
        ],
      ),
    );
  }
}
