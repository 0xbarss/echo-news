import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = false;

  void showRegisterDialog(BuildContext context,
      {String title = "Registration Failed", required String message}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
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
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) return;

    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore db = FirebaseFirestore.instance;

    try {
      QuerySnapshot querySnapshot = await db
          .collection("users")
          .where("username", isEqualTo: usernameController.text)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        if (context.mounted) {
          showRegisterDialog(context,
              message: "This username is already in use");
        }
        return;
      }

      final UserCredential userCredential =
          await auth.createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      db.collection("users").doc(userCredential.user!.uid).set({
        "username": usernameController.text,
        "e-mail": emailController.text,
        "password": passwordController.text
      });
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'network-request-failed') {
          showRegisterDialog(context,
              message: "There is no internet connection!");
        } else if (e.code == 'weak-password') {
          showRegisterDialog(context,
              message: "Please enter a stronger password");
        } else if (e.code == 'email-already-in-use') {
          showRegisterDialog(context, message: "This email is already in use");
        }
      }
      return;
    }

    if (context.mounted) {
      _navigateToLoginPage(context);
      showRegisterDialog(context,
          title: "Registration Successful!",
          message: "Registration Successful!");
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
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
              keyboardType: TextInputType.text,
              controller: usernameController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  label: Text("Username"),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.emailAddress,
              controller: emailController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email),
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
