import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'firebase_options.dart';
import 'localsession.dart';
import 'dashboard.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AImagetools',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
   return FutureBuilder<String?>(
      future: getToken(), 
      builder: (context, snapshot) {
        if (snapshot.data != null) { 
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AIConverterApp()),
          );
        });

        return const SizedBox();
        } else {
          return mm();  
        }
      },
    );
  }
}

