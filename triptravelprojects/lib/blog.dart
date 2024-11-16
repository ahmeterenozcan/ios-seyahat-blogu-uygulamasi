import 'package:flutter/material.dart';

class BlogPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Blog Yazıları: Seyahat ipuçları, en iyi destinasyonlar...',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
