import 'package:flutter/material.dart';
import 'package:login/screens/profile_screen.dart';
import 'package:login/screens/timer_screen.dart';

import '../widget/new_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TaskWhiz',
          style: TextStyle(
            fontFamily: 'Kablammo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red.shade800,
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.red.shade800,
        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week_outlined),
            label: 'Weekly',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_2_outlined),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "AddTask",
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => NewWidget()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return Container(
          child: Center(
            child: Text('Daily '),
          ),
        );
      case 1:
        return Container(
          child: Center(
            child: Text('Weekly Schedule'),
          ),
        );
      case 2:
        return TimerScreen();
      case 3:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}
