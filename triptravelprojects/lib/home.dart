import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> imageUrls = [];
  int maxRetryAttempts = 3; // Maksimum tekrar deneme sayısı

  @override
  void initState() {
    super.initState();
    fetchImages(); // API'den resimleri çek
  }

  Future<void> fetchImages() async {
    try {
      final response = await http.get(Uri.parse('https://localhost:7193/api/Blogs'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          imageUrls = data.map((item) {
            String url = item['blogImage'] as String;
            print('Resim URL: $url'); // Her resim URL'sini konsola yazdır
            return url;
          }).toList();
        });
      } else {
        print('Resimleri yükleme başarısız oldu: ${response.statusCode}');
      }
    } catch (e) {
      print('API çağrısı başarısız: $e');
    }
  }

  Future<Widget> loadImageWithRetry(String url, {int retryCount = 0}) async {
    try {
      // Eğer yükleme başarılı olursa, resmi geri döndür
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          if (retryCount < maxRetryAttempts) {
            print('Yüklenemeyen resim URL: $url, yeniden deniyor... ($retryCount)');
            return FutureBuilder(
              future: Future.delayed(Duration(seconds: 2), () => loadImageWithRetry(url, retryCount: retryCount + 1)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return snapshot.data as Widget;
                }
                return CircularProgressIndicator(); // Yükleniyor animasyonu
              },
            );
          } else {
            print('Yüklenemeyen resim URL: $url, tüm denemeler başarısız oldu.');
            return Icon(Icons.broken_image, size: 50, color: Colors.red); // Yüklenemeyen resimler için simge
          }
        },
      );
    } catch (e) {
      if (retryCount < maxRetryAttempts) {
        print('Yüklenemeyen resim URL: $url, yeniden deniyor... ($retryCount)');
        await Future.delayed(Duration(seconds: 2)); // Yeniden denemeden önce kısa bir bekleme
        return loadImageWithRetry(url, retryCount: retryCount + 1);
      } else {
        print('Yüklenemeyen resim URL: $url, tüm denemeler başarısız oldu.');
        return Icon(Icons.broken_image, size: 50, color: Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Plan the Easy Trip',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: imageUrls.isNotEmpty
                ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: FutureBuilder(
                    future: loadImageWithRetry(imageUrls[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return snapshot.data as Widget;
                      }
                      return CircularProgressIndicator(); // Yükleniyor animasyonu
                    },
                  ),
                );
              },
            )
                : Center(child: CircularProgressIndicator()), // Yükleniyor animasyonu
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _buildCategoryCard(Icons.local_dining, 'Restoranlar'),
                _buildCategoryCard(Icons.flight, 'Uçuşlar'),
                _buildCategoryCard(Icons.local_activity, 'Aktiviteler'),
                _buildCategoryCard(Icons.directions_car, 'Araba Kiralama'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                'Tatil Seyahat Bloguma Hoşgeldiniz',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                'Hoş geldiniz! Seyahat bloguma adım attığınız için çok mutluyum. Bu alanda, dünyayı keşfederken yaşadığım deneyimleri, gözlemlerimi ve tavsiyelerimi sizlerle paylaşacağım.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(IconData icon, String title) {
    return Card(
      color: Colors.grey[850],
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.pink),
            SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
