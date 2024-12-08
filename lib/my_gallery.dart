import 'package:aimagetools_new/localsession.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dashboard.dart';


class MyGalleryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Gallery',
      home: GalleryPage(),
    );
  }
}

class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<String> imageList = [];
  bool isLoading = true;
  String? token;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    try {
      final token = await getToken();
      final snapshot = await FirebaseFirestore.instance
          .collection('users') 
          .doc(token) 
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        setState(() {
          imageList = List<String>.from(snapshot.data()!['links'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching images: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
           Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AIConverterApp()),
            );
          },
        ),
        title: const Text(
          'My Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: imageList.isEmpty
                  ? EmptyGalleryPlaceholder()
                  : GalleryGrid(imageList: imageList),
            ),
    );
  }
  }


class EmptyGalleryPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(Icons.image, size: 100, color: Color(0xFFF39200)),
        SizedBox(height: 16),
        Text(
          'No images uploaded yet. Add images to Firestore to see them here.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

class GalleryGrid extends StatelessWidget {
  final List<String> imageList;

  GalleryGrid({required this.imageList});

  Future<void> deleteLink(String linkToDelete, BuildContext context) async {
  try {
     final tokenn = await getToken();
    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(tokenn);

    await userRef.update({
      'links': FieldValue.arrayRemove([linkToDelete]),
    });
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) =>  MyGalleryApp()),
);
    print('Link berhasil dihapus!');
  } catch (e) {
    print('Gagal menghapus link: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10, 
      ),
      itemCount: imageList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onLongPress: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Hapus Gambar'),
                        onTap: () {
                          Navigator.pop(context);
                           deleteLink(imageList[index],context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Gambar berhasil dihapus'),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.cancel),
                        title: const Text('Batal'),
                        onTap: () {
                          Navigator.pop(context); 
                        },
                      ),
                    ],
                  ),
                );
              } );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageList[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.red,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
