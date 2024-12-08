import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = const FlutterSecureStorage();

Future<void> saveToken(String token) async {
  await _secureStorage.write(key: 'authToken', value: token);
  print('Token saved securely.');
}

Future<void> saveprofile(String profile) async {
  await _secureStorage.write(key: 'profile', value: profile);
  print('profile saved securely.');
}

Future<String?> getToken() async {
  return await _secureStorage.read(key: 'authToken');
  
  //kebutuhan debuging 
  //print('username$AuthToken');
  
}

Future<void> savecon(String con) async {
  await _secureStorage.write(key: 'con', value: con);
}
Future<String?> getcon() async {
  return await _secureStorage.read(key: 'con');
  
}

Future<String?> getprofile() async {
  return await _secureStorage.read(key: 'profile');
  
}
Future<void> hapuscon() async {
  await _secureStorage.delete(key: 'con');
  print('Berhasil membersihkan data.');
}

Future<void> hapuspro() async {
  await _secureStorage.delete(key: 'profile');
  print('Berhasil membersihkan data profile.');
}