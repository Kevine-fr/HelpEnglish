import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:helpenglish/Views/Admin/HomePage.dart';
import 'package:helpenglish/Views/Client/HomePage.dart';
import 'package:helpenglish/Views/LogIn.dart';
import 'package:helpenglish/Views/Professor/HomePage.dart';
import 'package:helpenglish/Views/Routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double ResponsiveWidth(double width, BuildContext context) {
      return 411.42* width* MediaQuery.of(context).size.width;
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Help English',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/login': (context) => SignInScreen(),
        '/homeClient': (context) => HomePageClient(),
        '/homeAdmin': (context) => HomePageAdmin(),
        '/homeProfessor': (context) => HomePageProfessor(),
      },
      home: AuthScreen(),
    );
  }
}
