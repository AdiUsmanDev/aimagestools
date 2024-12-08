import 'package:flutter/material.dart';

class ConvertingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _ConvertingScreen(),
    );
  }
}

class _ConvertingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          'Convert Video',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white, // Latar belakang putih
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
            children: [
              ElevatedButton(
                onPressed: null, 
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  backgroundColor: Colors.orange,
                  disabledBackgroundColor: Colors.orange,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "Converting to ...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
