import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = false;

  void _navigateToLoginPage(BuildContext context) {
    if (context.mounted) {
      Navigator.pop(context);
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
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  label: Text("Username"),
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.zero),
                  )),
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
                      onTap: () =>
                          setState(() {
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
              onPressed: () => _navigateToLoginPage(context),
              child: const Text("Register")),
        ],
      ),
    );
  }
}
