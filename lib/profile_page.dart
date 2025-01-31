import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // ✅ Install the package
import 'dart:io';
import 'database_helper.dart';

class ProfilePage extends StatefulWidget {
  final int userId;

  ProfilePage({this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  File _profileImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final db = DatabaseHelper.instance;
    final user = await db.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _usernameController.text = user['username'];
        _profileImage = user['profile_picture'] != null
            ? File(user['profile_picture'])
            : null;
      });
    }
  }

  Future<void> _updateProfile() async {
    final db = DatabaseHelper.instance;
    await db.updateUserProfile(
      widget.userId,
      _usernameController.text,
      _passwordController.text.isNotEmpty ? _passwordController.text : null,
      _profileImage?.path,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile updated successfully!')),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                _profileImage != null ? FileImage(_profileImage) : null,
                child: _profileImage == null
                    ? Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: Text("Update Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
