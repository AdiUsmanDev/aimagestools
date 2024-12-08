import 'package:aimagetools_new/localsession.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'resolusi.dart';
import 'croppingai.dart';
import 'upscalingimage.dart';
import 'copingaivideo.dart';



class selectimage extends StatefulWidget {
  @override
  _selectimage createState() => _selectimage();
}

class _selectimage extends State<selectimage> {
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
      backgroundColor: Color.fromARGB(246, 255, 255, 255),
      appBar: AppBar(
     backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'My Gallery',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:  isLoading
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

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, 
        crossAxisSpacing: 10, 
        mainAxisSpacing: 10, 
      ),
      itemCount: imageList.length,
      itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () async {
    String? con = await getcon();
   switch (con) {
    case 'resolusi':
     Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConvertVideoScreen(imageUrl: imageList[index]),
            ),
          );
      break;
    case 'upscaling':

      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Upscalingimage(imageUrl: imageList[index]),
            ),
          );
      break;
    case 'cropingai':
 
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  Croppingai(imageUrl: imageList[index]),
            ),
          );
      break;
    case 'cropingaivideo':
 
      Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  Croppingaivideo(imageUrl: imageList[index]),
            ),
          );
      break;
    default:

      print('Kondisi tidak valid');
      break;
  }
    
        },
      
        child:Container(
          decoration: BoxDecoration(
            color: Color(0xFFD3D3D3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.network(
            imageList[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
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
