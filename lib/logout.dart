import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _secureStorage = const FlutterSecureStorage();
final GoogleSignIn googleSignIn = GoogleSignIn();

Future<void> clearSession() async {
  await _secureStorage.deleteAll();
  print('Berhasil membersihkan data melanjutkan logout.');
  logoutUser();
}

Future<void> logoutUser() async {
  try {
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    print("User logged out from Firebase and Google");
  } catch (e) {
    print("Error during logout: $e");
  }
}
