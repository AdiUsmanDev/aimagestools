import 'package:aimagetools_new/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'localsession.dart';
import 'dashboard.dart';

class daftar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color.fromARGB(235, 255, 255, 255),
      ),
      home: RegistrationForm(),
    );
  }
}

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String hash(String password) {
    final bytes = utf8.encode(password);
    final hashedPassword = sha256.convert(bytes);
    return hashedPassword.toString();
  }

  Future<bool> isEmailExists(String email) async {
  final snapshot = await _database
      .child('users')
      .orderByChild('email')
      .equalTo(email)
      .once();

  return snapshot.snapshot.value != null; 
}

  void _registerUser() async {
    String pw = hash(_passwordController.text);

    bool emailExists = await isEmailExists(_emailController.text);
      if (emailExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email sudah digunakan!')),
      );
    } else {

    if (_formKey.currentState!.validate()) {
      String userId = _database.child('users').push().key!;
      _database.child('users/$userId').set({
        'name': _nameController.text,
        'email': _emailController.text,
        'password': pw,
      }).then((_){
        saveUserWithLinks(uid: _emailController.text, links: ['']);
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();

        

      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $error')),
        );
      });
    }
  }
  }

  Future<void> saveUserWithLinks({
    required String uid,
    required List<String> links,
  }) async {
    try {
      final Map<String, dynamic> userData = {
        'uid': uid,
        'links': links,
      };

      await firestore.collection('users').doc(uid).set(userData);
      await saveToken(uid);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pendaftaran berhasil!')),
      );

      Navigator.push( context,
             MaterialPageRoute(
             builder: (context) => AIConverterApp(),
              ),
                      );
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.orange,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
              Navigator.push(
              context,
                MaterialPageRoute(builder: (context) => mm()),
              );
          },
        ),
        title: const Text('Daftar Akun Baru',
         style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.all(16.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Form Pendaftaran',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                   
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi',
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kata sandi tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14.0, horizontal: 30.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: const Text(
                      'Daftar',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                       Navigator.push( context,
                        MaterialPageRoute(
                        builder: (context) => mm(),
                          ),
                      );
                    },
                    child:RichText(
                    text: TextSpan(
                      text: "Sudah punya akun? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Masuk",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
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
