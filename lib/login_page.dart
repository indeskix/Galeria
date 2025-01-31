import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _authenticate(bool isLogin) async {
    final db = DatabaseHelper.instance;
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (isLogin) {
      final user = await db.getUser(username, password);
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('loggedInUserId', user['id']);

        Navigator.pop(context, user['id']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
      }
    } else {
      await db.insertUser(username, password);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Account created')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Column(
        children: [
          TextField(controller: _usernameController, decoration: InputDecoration(labelText: "Username")),
          TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
          ElevatedButton(onPressed: () => _authenticate(true), child: Text("Login")),
          ElevatedButton(onPressed: () => _authenticate(false), child: Text("Register")),
        ],
      ),
    );
  }
}
