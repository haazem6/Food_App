import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'authentication/login_screen.dart';
import 'main_screens/home_screen.dart';


Future<void> main() async
{
  await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
        apiKey: "AIzaSyAoMa7WiszI6dvKTMPlfJ4SlXGA5e9lG3w",
        authDomain: "foodpanda-clone-app-e5817.firebaseapp.com",
        projectId: "foodpanda-clone-app-e5817",
        storageBucket: "foodpanda-clone-app-e5817.appspot.com",
        messagingSenderId: "475979426834",
        appId: "1:475979426834:web:460717287413f0e6a43ccb"
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Web Portal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: FirebaseAuth.instance.currentUser == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}


