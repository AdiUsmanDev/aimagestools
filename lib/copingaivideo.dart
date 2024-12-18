import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'dashboard.dart';

class Croppingaivideo extends StatefulWidget {
  final String imageUrl;

  const Croppingaivideo({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  State<Croppingaivideo> createState() => _ConvertVideoScreenState();
}

class _ConvertVideoScreenState extends State<Croppingaivideo> {
  String? selectedratio;
  String baseUrl =
      "https://res.cloudinary.com/dyeo7dpua/image/upload//c_fill,g_face,h_300,w_300/r_max/f_auto/";
  @override
  Widget build(BuildContext context) {
     List<String> parts = widget.imageUrl.split('/');
  String fileName = parts.last;
     final String fullImageUrl = baseUrl + fileName;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Images Filters',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: Colors.orange,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.imageUrl,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.red,
                      size: 100,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: selectedratio,
                decoration: const InputDecoration(
                  labelText: 'Ukuran',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '100', child: Text('100px')),
                  DropdownMenuItem(value: '300', child: Text('300px')),
                  DropdownMenuItem(value: '500', child: Text('500px')),
                  DropdownMenuItem(value: '700', child: Text('700px')),
                  DropdownMenuItem(value: '1000', child: Text('1000px')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedratio = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Center(
                child: ElevatedButton(
                  onPressed: selectedratio == null
                      ? null
                      : () {
                          String updatedUrl = fullImageUrl.replaceFirst(
                            RegExp(r'w_\d+'),
                            'w_${selectedratio == '100' ? '100' : selectedratio == '300' ? '300' : selectedratio == '500' ? '500': selectedratio == '700' ? '700' : '1000'}',
                    
                          ).replaceFirst(
                            RegExp(r'h_\d+'), 
                          'h_${selectedratio == '100' ? '100' : selectedratio == '300' ? '300' : selectedratio == '500' ? '500': selectedratio == '700' ? '700' : '1000'}',
                    
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConvertingScreen(
                                quality: selectedratio!,
                                updatedUrl: updatedUrl,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 12.0),
                  ),
                  child: const Text('Convert Now!',
                  style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConvertingScreen extends StatelessWidget {
  final String quality;
  final String updatedUrl;

  const ConvertingScreen({
    Key? key,
    required this.quality,
    required this.updatedUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
 Future.delayed(const Duration(seconds: 10), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ImageAnimationScreen(imageUrl: updatedUrl),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = 0.0;
            var end = 1.0;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);

            return FadeTransition(opacity: opacityAnimation, child: child);
          },
        ),
      );
    });


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Converting...',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Converting to $quality...',
              style: const TextStyle(fontSize: 16.0, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

 

class ImageAnimationScreen extends StatefulWidget {
  final String imageUrl; 

  const ImageAnimationScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _ImageAnimationScreenState createState() => _ImageAnimationScreenState();
}

class _ImageAnimationScreenState extends State<ImageAnimationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), 
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
    )..addListener(() {
        setState(() {}); 
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

  Future<void> _downloadImage(String url) async {
    try {
      Dio dio = Dio();
      String fileName = url.split('/').last; 
      var response = await dio.download(url, '/storage/emulated/0/Download/$fileName');
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil diunduh!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat mengunduh gambar.')),
      );
    }
  }

  void _checkPermissions() async {
  PermissionStatus status = await Permission.storage.status;

  if (status.isGranted) {
    _downloadImage(widget.imageUrl);
  } else {
    status = await Permission.storage.request();
    if (status.isGranted) {
      _downloadImage(widget.imageUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Izin akses penyimpanan ditolak.')),
      );
    }
  }
}


    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); 
          },
        ),
        title: const Text(
          'Result Proses',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar dengan animasi efek petasan (zoom in dan out)
            Transform.scale(
              scale: _scaleAnimation.value,
              child: Image.network(
                widget.imageUrl,
                height: 200, // Ukuran gambar
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    color: Colors.red,
                    size: 100,
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
            const SizedBox(height: 20),
             ElevatedButton(
      style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white, 
    foregroundColor: Colors.white,
              ),
              onPressed: () {
             _checkPermissions();
              },
              child: const Text('Download Gambar',
              style: TextStyle(color: Colors.orange)),
            ),
              const SizedBox(height: 20),
             ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.white, 
    foregroundColor: Colors.white,
              ),
              onPressed: () {
             Navigator.push(
           context,
            MaterialPageRoute(
              builder: (context) => AIConverterApp(),
                ),
                  );
              },
              child: const Text('Edit Lagi',
              style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ),
    );
  }
}
