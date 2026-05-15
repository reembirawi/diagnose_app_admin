import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:diagnose_app/admin_dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFDDDDFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFEEC3),
            Color(0xFFEEC395),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Welcome back!',
                    style: GoogleFonts.titanOne(
                      fontSize: 35,
                      fontWeight: FontWeight(500),
                      color: Color.fromRGBO(77, 81, 162, 100),
                    ),
                  ),
                  SizedBox(height: 16),

                  _buildInputField("Email", _emailController, context),
                  SizedBox(height: 16),

                  _buildInputField("Password", _passwordController, context),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.85,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4D51A2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              await auth.signInWithEmailAndPassword(
                                email: _emailController.text.trim(),
                                password: _passwordController.text.trim(),
                              );

                              final uid =
                                  FirebaseAuth.instance.currentUser!.uid;

                              final doc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get();

                              final role = doc['role'];

                              if (role == "admin") {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AdminDashboard(),
                                  ),
                                );
                              } 
                            } on FirebaseAuthException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.message ?? "Login failed"),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildInputField(
  String hint,
  TextEditingController controller,
  BuildContext context,
) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.85,
    height: 55,
    child: TextFormField(
      controller: controller,
      obscureText: hint == "Password",
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,

        hintText: hint,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4D51A2), width: 0.8),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4D51A2), width: 1.5),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4D51A2), width: 0.8),
        ),
      ),
    ),
  );
}
