import 'package:flutter/material.dart';
import 'package:gallery_app/home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.amber,
      ),
      debugShowCheckedModeBanner: false,
      home: GalleryApp(),
    );
  }
}

class GalleryApp extends StatefulWidget {
  @override
  _GalleryAppState createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  int _selectedIndex = 0;
  List<bool> favorites = List.generate(14, (index) => false);

  final List<Map<String, String>> List_Item = [
    {'pic': 'assets/img/1.jpg'},
    {'pic': 'assets/img/2.jpg'},
    {'pic': 'assets/img/3.jpg'},
    {'pic': 'assets/img/4.jpg'},
    {'pic': 'assets/img/5.jpg'},
    {'pic': 'assets/img/6.jpg'},
    {'pic': 'assets/img/7.jpg'},
    {'pic': 'assets/img/8.jpg'},
    {'pic': 'assets/img/9.jpg'},
    {'pic': 'assets/img/10.jpg'},
    {'pic': 'assets/img/11.jpg'},
    {'pic': 'assets/img/12.jpg'},
    {'pic': 'assets/img/13.jpg'},
    {'pic': 'assets/img/14.jpg'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> favoriteItems = [];
    for (int i = 0; i < List_Item.length; i++) {
      if (favorites[i]) {
        favoriteItems.add(List_Item[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Alexa Gallery App'),
        backgroundColor: Colors.black,
      ),
      body: _selectedIndex == 0
          ? GalleryPage(
        items: List_Item,
        favorites: favorites,
        onFavoriteChanged: (index) {
          setState(() {
            favorites[index] = !favorites[index];
          });
        },
      )
          : FavoritesPage(
        items: favoriteItems,
        onFavoriteChanged: (index) {
          setState(() {
            int originalIndex = List_Item.indexOf(favoriteItems[index]);
            favorites[originalIndex] = !favorites[originalIndex];
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Ulubione',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
