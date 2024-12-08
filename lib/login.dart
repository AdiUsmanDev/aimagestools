import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_database/firebase_database.dart';
import 'localsession.dart';
import 'dashboard.dart';
import 'daftar.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestoreq;

class mm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Aimagestools',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Directionality(
        textDirection: TextDirection.ltr,
        child: SignInScreen(),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  bool _isPasswordVisible = false;
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<User?> signInWithGoogle() async {
    try {
      await googleSignIn.signOut();
      await _auth.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      print('Google User: $googleUser');
      if (googleUser != null) {
    
      final User? user = _auth.currentUser;

     if (user != null) {
    print("Login berhasil: ${googleUser.displayName}");
    print("Email: ${googleUser.email}");
    print("UID: ${googleUser.id}");
    print("Photo URL: ${googleUser.photoUrl}");
  } else {
    print("Tidak ada user yang sedang login.");

     print("Login berhasil: ${googleUser.displayName}");
    print("Email: ${googleUser.email}");
    print("UID: ${googleUser.id}");
    print("Photo URL: ${googleUser.photoUrl}");
  }
     
      final snapshot = await  firestoreq.FirebaseFirestore.instance
    .collection('users') 
    .doc(googleUser.email) 
    .get();
     if(snapshot.exists){
       final  profilelink = googleUser.photoUrl ?? "nonenul";
        final userName = googleUser.email;
       await saveprofile(profilelink);
       await saveToken(userName);
         Navigator.push( context,
             MaterialPageRoute(
             builder: (context) => AIConverterApp(),
              ),
         );
        print('Login Berhasil: ${user?.displayName}');
        return user;
      }else{
        saveUserWithLinks(uid: googleUser.email , links:['']);
      }
      }
    } catch (e) {
      print('Error saat login dengan Google: $e');
    }
    return null;
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

    await firestoreq.FirebaseFirestore.instance.collection('users').doc(uid).set(userData);

    saveToken(uid);
         Navigator.push( context,
             MaterialPageRoute(
             builder: (context) => AIConverterApp(),
              ),
         );
  } catch (e) {
    print('Error: $e');
  }
}

  Future<bool> loginUser(String userid, String password) async {
  final DatabaseReference _database = FirebaseDatabase.instanceFor(app: Firebase.app(), databaseURL: "https://aimagetools-1df21-default-rtdb.firebaseio.com/").reference();
  
  try {
     Query query = _database.child("users").orderByChild("email").equalTo(userid);
    DataSnapshot snapshot = await query.get();

    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      
      print(snapshot.value);
      final storedPasswordHash =  data.values.first['password'] ?? '';
    
      final inputPasswordHash = sha256.convert(utf8.encode(password)).toString();

      if (storedPasswordHash == inputPasswordHash) {
        saveToken(userid);
         Navigator.push( context,
             MaterialPageRoute(
             builder: (context) => AIConverterApp(),
              ),
                      );
        print("Login berhasil");
        return true;
      } else {
        print("Password salah");
        return false;
      }
        }
    else {
      print("Username tidak ditemukan");
      return false;
    }
  }catch (e) {
    print("Error saat login: $e");
    return false;
        }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
               
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 30),

                  
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            String username = _usernameController.text;
                            String password = _passwordController.text;

                            bool loginSuccess = await loginUser(username, password);

                            if (loginSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login berhasil')),

                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login gagal: Email atau password salah')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login with Username',
                            style: TextStyle(fontSize: 16 ,color: Colors.white),
                          ),
                        ),
                      ),

                     const SizedBox(height: 16),
                        
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: signInWithGoogle,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Login with Google',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
          const SizedBox(height: 20),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: GestureDetector(
                  onTap: () {
             Navigator.push( context,
             MaterialPageRoute(
             builder: (context) => daftar(),
              ),
                      );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Belum punya akun? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: "Daftar",
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
