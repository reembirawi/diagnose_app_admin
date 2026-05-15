// import 'package:diagnose_app/homePage.dart';
// import 'package:diagnose_app/homePage_arabic.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_floating_bottom_bar/flutter_floating_bottom_bar.dart';
// import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:diagnose_app/login_page.dart';
// import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DiagnoseApp());
}

class DiagnoseApp extends StatelessWidget {
  const DiagnoseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: LoginForm());
  }
}
