import 'package:flutter/material.dart';
import 'package:TaskWhiz/screens/tasks/add_task_screen.dart';
import 'package:TaskWhiz/screens/tasks/all_tasks_screen.dart';
import 'package:TaskWhiz/screens/auth/profile_screen.dart';
import 'package:TaskWhiz/screens/timer/timer_screen.dart';

import 'tasks/daily_schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

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
            label: 'Tasks',
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddTaskScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0:
        return DailySchedule();
      case 1:
        return AllTasksScreen();
      case 2:
        return TimerScreen();
      case 3:
        return ProfileScreen();
      default:
        return Container();
    }
  }
}
