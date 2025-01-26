import 'package:flutter/material.dart';
import 'package:gallery_app/home.dart';
import 'package:gallery_app/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // For older Flutter versions, 'accentColor' is fine
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
  bool _isLoggedIn = false;
  String _loggedInUsername = "";

  // Pre-generate a list of booleans for Favorites.
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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('loggedIn') ?? false;
    final username = prefs.getString('loggedInUser') ?? "";

    setState(() {
      _isLoggedIn = loggedIn;
      _loggedInUsername = username;
    });

    if (!loggedIn) {
      // If not logged in, go straight to login
      await _navigateToLogin();
    } else {
      // If already logged in, load that user's favorites
      final userFavorites = prefs.getStringList('favorites_' + _loggedInUsername) ?? [];
      setState(() {
        favorites = _generateFavorites(userFavorites);
      });
    }
  }

  Future<void> _navigateToLogin() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );

    if (result != null) {
      // 'result' is the username from LoginPage
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isLoggedIn = true;
        _loggedInUsername = result;
        // Optionally reset tab to Gallery so the bar refreshes
        _selectedIndex = 0;
      });
      prefs.setBool('loggedIn', true);
      prefs.setString('loggedInUser', _loggedInUsername);

      // Load favorites for that user
      final userFavorites = prefs.getStringList('favorites_' + _loggedInUsername) ?? [];
      setState(() {
        favorites = _generateFavorites(userFavorites);
      });
    } else {
      // If user backs out without logging in, close app
      SystemNavigator.pop();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('loggedIn', false);
    prefs.remove('loggedInUser');
    setState(() {
      _isLoggedIn = false;
      _loggedInUsername = "";
      // Clear in-memory favorites so it won’t appear for the next user
      favorites = List.generate(List_Item.length, (index) => false);
    });
    await _navigateToLogin();
  }

  List<bool> _generateFavorites(List<String> userFavorites) {
    List<bool> result = List.generate(List_Item.length, (index) => false);
    for (int i = 0; i < List_Item.length; i++) {
      if (userFavorites.contains(List_Item[i]['pic'])) {
        result[i] = true;
      }
    }
    return result;
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      if (_isLoggedIn) {
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
    // Build list of favorite items for Favorites page
    List<Map<String, String>> favoriteItems = [];
    for (int i = 0; i < List_Item.length; i++) {
      if (favorites[i]) {
        favoriteItems.add(List_Item[i]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,

        // Show "Login" if not logged in, otherwise "Gallery App"
        title: Column(
          children: <Widget>[
            Text(
              _isLoggedIn ? 'Gallery of: $_loggedInUsername' : 'Login',
            ),
          ],
        ),
      ),
      body: _selectedIndex == 0
          ? GalleryPage(
        items: List_Item,
        favorites: favorites,
        onFavoriteChanged: (index) async {
          setState(() {
            favorites[index] = !favorites[index];
          });
          final prefs = await SharedPreferences.getInstance();
          List<String> userFavorites = [];
          for (int i = 0; i < List_Item.length; i++) {
            if (favorites[i]) {
              userFavorites.add(List_Item[i]['pic']);
            }
          }
          prefs.setStringList('favorites_' + _loggedInUsername, userFavorites);
        },
      )
          : FavoritesPage(
        items: favoriteItems,
        onFavoriteChanged: (index) async {
          int originalIndex = List_Item.indexOf(favoriteItems[index]);
          setState(() {
            favorites[originalIndex] = !favorites[originalIndex];
          });
          final prefs = await SharedPreferences.getInstance();
          List<String> userFavorites = [];
          for (int i = 0; i < List_Item.length; i++) {
            if (favorites[i]) {
              userFavorites.add(List_Item[i]['pic']);
            }
          }
          prefs.setStringList('favorites_' + _loggedInUsername, userFavorites);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Galeria',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Ulubione',
          ),
          BottomNavigationBarItem(
            icon: Icon(_isLoggedIn ? Icons.logout : Icons.vpn_key),
            label: _isLoggedIn ? 'Logout' : 'Login',
          ),
        ],
      ),
    );
  }
}
