import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late User? _user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  int _selectedImageIndex = 0;
  bool _userDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadUserData(); // Load user data when the screen is initialized
  }

  Future<void> _loadUserData() async {
    // Assuming _user is not null here
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('User_Details')
        .doc(_user!.uid)
        .get();

    if (snapshot.exists) {
      // User data exists in the database
      setState(() {
        _nameController.text =
            snapshot.data()!['name'] ?? _generateRandomName();
        _selectedImageIndex = snapshot.data()!['selectedImageIndex'] ?? 0;
        _userDataLoaded = true;
      });
    } else {
      // User data doesn't exist, generate a random name and select a random image
      _nameController.text = _generateRandomName();
      _selectedImageIndex = _generateRandomImageIndex();
      _saveDetails(); // Save the initial details to the database
    }
  }

  String _generateRandomName() {
    List<String> adjectives = ['Crazy', 'Silly', 'Wacky', 'Whimsical', 'Zany'];
    List<String> nouns = [
      'Elephant',
      'Banana',
      'Penguin',
      'Sunflower',
      'Pizza'
    ];

    Random random = Random();
    String adjective = adjectives[random.nextInt(adjectives.length)];
    String noun = nouns[random.nextInt(nouns.length)];

    return '$adjective $noun';
  }

  int _generateRandomImageIndex() {
    Random random = Random();
    return random.nextInt(6);
  }

  @override
  Widget build(BuildContext context) {
    if (!_userDataLoaded) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return _buildProfile();
  }

  Widget _buildProfile() {
    return _user != null
        ? SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              CircleAvatar(
                radius: 70,
                backgroundImage: AssetImage(
                    'assets/images/pic${_selectedImageIndex + 1}.png'),
              ),
              SizedBox(height: 16),
              Text(
                'Hello,',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SofiaSans',
                ),
              ),
              SizedBox(height: 10),
              Text(
                _nameController.text,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SofiaSans',
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Email: ${_user!.email}',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SofiaSans',
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => _buildEditProfileDialog(),
                      );
                    },
                  ),
                  SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.red.shade500,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                  ),
                ],
              ),
            ],
          ))
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  Widget _buildEditProfileDialog() {
    return AlertDialog(
      title: Text(
        'Edit Profile',
        style: TextStyle(
          fontFamily: 'SofiaSans',
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Your name'),
              style: TextStyle(
                fontFamily: 'SofiaSans',
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16),
            _buildImagePicker(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'SofiaSans',
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _saveDetails();
            Navigator.pop(context); // Close the dialog
          },
          child: Text(
            'Save',
            style: TextStyle(
              fontFamily: 'SofiaSans',
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Profile Image:',
          style: TextStyle(
              fontFamily: 'SofiaSans',
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: List.generate(6, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedImageIndex = index;
                });
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: _selectedImageIndex == index
                    ? Colors.blue.withOpacity(0.9)
                    : Colors.transparent,
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      AssetImage('assets/images/pic${index + 1}.png'),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _saveDetails() {
    final userDetails = {
      'name': _nameController.text,
      'selectedImageIndex': _selectedImageIndex,
    };

    // Assuming _user is not null here
    FirebaseFirestore.instance
        .collection('User_Details')
        .doc(_user!.uid)
        .set(userDetails)
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User details saved successfully'),
        ),
      );
      _loadUserData();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save user details: $error'),
        ),
      );
    });
  }
}
