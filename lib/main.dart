import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'home.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
    statusBarColor: Colors.black,
  ));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(backgroundColor: Colors.black),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: Colors.white,
        ),
      ),
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
  int _userId;
  List<int> favorites = [];
  List<Map<String, dynamic>> images = [];

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final db = DatabaseHelper.instance;
    await db.insertLocalImages();
    await _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('loggedInUserId');

    if (userId == null) {
      await _navigateToLogin();
    } else {
      setState(() {
        _userId = userId;
      });
      await _loadImages();
      await _loadFavorites();
    }
  }

  Future<void> _navigateToLogin() async {
    final userId = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    if (userId != null) {
      setState(() {
        _userId = userId;
      });
      await _loadImages();
      await _loadFavorites();
    } else {
      SystemNavigator.pop();
    }
  }

  Future<void> _loadImages() async {
    final db = DatabaseHelper.instance;
    final imageList = await db.getImages();
    setState(() {
      images = imageList;
    });
  }

  Future<void> _loadFavorites() async {
    final db = DatabaseHelper.instance;
    final favList = await db.getFavorites(_userId);
    setState(() {
      favorites = favList;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserId');

    setState(() {
      _userId = null;
      favorites = [];
      images = [];
    });

    await _navigateToLogin();
  }

  Future<void> _toggleFavorite(int imageId) async {
    final db = DatabaseHelper.instance;
    await db.toggleFavorite(_userId, imageId);
    await _loadFavorites();
  }

  Future<void> _addNewImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final db = DatabaseHelper.instance;

      // Save the image path to the database
      await db.insertImage(pickedFile.path);

      // Refresh the gallery to show the new image
      await _loadImages();
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      if (_userId != null) {
        _logout();
      } else {
        _navigateToLogin();
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Galeria'),
      ),
      body: _selectedIndex == 0
          ? GalleryPage(
        userId: _userId,
        images: images,
        favorites: favorites,
        onFavoriteChanged: (imageId) {
          _toggleFavorite(imageId);
        },
      )
          : _selectedIndex == 1
          ? FavoritesPage(
        userId: _userId,
        images: images.where((img) => favorites.contains(img['id'])).toList(),
        onFavoriteChanged: (imageId) {
          _toggleFavorite(imageId);
        },
      )
          : _selectedIndex == 2
          ? ProfilePage(userId: _userId)
          : Container(),

      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: _addNewImage,
        backgroundColor: Colors.amber,
        child: Icon(Icons.add, color: Colors.black),
      )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Galeria'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Ulubione'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(
            icon: Icon(_userId != null ? Icons.logout : Icons.login),
            label: _userId != null ? 'Wyloguj' : 'Zaloguj',
          ),
        ],
      ),
    );
  }
}
