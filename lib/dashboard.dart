import 'package:flutter/material.dart';
import 'my_gallery.dart';
import 'requestimage.dart';
import 'logout.dart';
import 'selectimage.dart';
import 'localsession.dart';
import 'login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AIConverterApp extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<AIConverterApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String? con = await getcon();
      if (con != null && con.isNotEmpty) {
        await hapuscon();
      }
    });
  }

  Future<void> deleteUserByEmail(String? email) async {
  try {
    final querySnapshot = await FirebaseDatabase.instance
        .ref('users')
        .orderByChild('email') // Field email pada data
        .equalTo(email)
        .once();

    if (querySnapshot.snapshot.value != null) {
      Map<dynamic, dynamic> users = querySnapshot.snapshot.value as Map<dynamic, dynamic>;
      users.forEach((key, value) async {
        await FirebaseDatabase.instance.ref('users/$key').remove();
        print('Data dengan email $email berhasil dihapus');
      });
    } else {
      print('Data dengan email $email tidak ditemukan');
    }
  } catch (e) {
    print('Error saat menghapus data: $e');
  }
}

Future<void> deleteEmailFromFirestore(String? email) async {
  try {
    await FirebaseFirestore.instance.collection('users').doc(email).delete();
    print('Email berhasil dihapus dari Firestore');
  } catch (e) {
    print('Error saat menghapus email dari Firestore: $e');
  }
}


  Future<String> getProfileImageUrl() async {
    String? profile = await getprofile();
    if(profile != null && profile.isNotEmpty){
      return profile;
    }else if(profile == 'nonenul'){
      return 'https://cdn.kibrispdr.org/data/7028/gambar-profil-kosong-36.jpg';
    }

    
    return 'https://cdn.kibrispdr.org/data/7028/gambar-profil-kosong-36.jpg'; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Converter',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                FutureBuilder<String>(
                  future: getProfileImageUrl(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircleAvatar(
                        radius: 25,
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return CircleAvatar(
                        radius: 25,
                        child: Icon(Icons.error, color: Colors.red),
                      );
                    } else if (snapshot.hasData) {
                      final imageUrl = snapshot.data!;
                      return PopupMenuButton<String> (
                        onSelected: (value) async {
                          if (value == 'profile') {
                            print('Navigasi ke halaman profil');
                          } else if (value == 'logout') {
                            clearSession();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => mm()),
                            );
                          } else if (value == 'Hapus_Akun') {
                             bool? confirm = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Konfirmasi Hapus Akun'),
                                    content: Text('Apakah Anda yakin ingin menghapus akun ini? Tindakan ini tidak dapat dibatalkan.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false); 
                                        },
                                        child: Text('Batal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(true); 
                                        },
                                        child: Text('Hapus', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  );
                                },
                              );

                              // Jika pengguna mengonfirmasi
                              if (confirm == true) {
                                String? mail = await getToken();
                                print(mail);
                                deleteUserByEmail(mail);
                                deleteEmailFromFirestore(mail);
                                clearSession();
                                hapuspro();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => mm()),
                                );
                              }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'Hapus_Akun',
                            child: Text('Delete Akun'),
                          ),
                          PopupMenuItem(
                            value: 'logout',
                            child: Text('Logout'),
                          ),
                          
                        ],
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(imageUrl),
                          radius: 25,
                        ),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 25,
                        child: Icon(Icons.person, color: Colors.grey),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  DashboardButton(
                    icon: Icons.image,
                    label: 'Upload Image',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => upload()),
                      );
                    },
                  ),
                  DashboardButton(
                    icon: Icons.photo_library,
                    label: 'My Gallery',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyGalleryApp()),
                      );
                    },
                  ),
                  DashboardButton(
                    icon: Icons.crop,
                    label: 'Resolusi Images',
                    onPressed: () {
                      savecon('resolusi');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => selectimage()),
                      );
                    },
                  ),
                  DashboardButton(
                    icon: Icons.crop,
                    label: 'Upscaling Images',
                    onPressed: () {
                      savecon('upscaling');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => selectimage()),
                      );
                    },
                  ),
                  DashboardButton(
                    icon: Icons.crop,
                    label: 'Croping AI Images',
                    onPressed: () {
                      savecon('cropingai');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  selectimage()),
                      );
                    },
                  ),
                  DashboardButton(
                    icon: Icons.crop,
                    label: 'Images AI Face',
                    onPressed: () {
                      savecon('cropingaivideo');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => selectimage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  DashboardButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange, Colors.yellow],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
