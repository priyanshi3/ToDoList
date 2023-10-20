import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:TaskWhiz/screens/tasks/add_task_screen.dart';

class DailySchedule extends StatefulWidget {
  const DailySchedule({Key? key}) : super(key: key);

  @override
  State<DailySchedule> createState() => _DailyScheduleState();
}

class _DailyScheduleState extends State<DailySchedule> {
  late User? _user = FirebaseAuth.instance.currentUser;
  AudioPlayer audioPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Task>>(
        future: getIncompleteTasksForToday(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No incomplete tasks for today.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18.0, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Make the font bold
                    ),
                  ),
                  subtitle: Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14.0, // Adjust the font size as needed
                    ),
                  ),
                  trailing: Checkbox(
                    value: task.completed,
                    onChanged: (bool? value) async {
                      await updateTaskCompletionStatus(task, value ?? false);
                      // Update only the local list, not the one obtained from the snapshot
                      setState(() {
                        task.completed = value ?? false;
                      });
                      _taskCompleted();
                    },
                    shape: CircleBorder(),
                    side: BorderSide(color: Colors.white),
                    activeColor: Colors.redAccent,
                    checkColor: Colors.white,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> updateTaskCompletionStatus(Task task, bool completed) async {
    try {
      if (task.repeating) {
        // If it's a repeating task, update the date to the next occurrence
        DateTime nextOccurrence = task.date.add(Duration(days: 1));
        await FirebaseFirestore.instance
            .collection('Tasks')
            .doc(task.id)
            .update({
          'completed': completed,
          'date': nextOccurrence,
        });
      } else {
        // If it's a one-time task, update the completion status directly
        await FirebaseFirestore.instance
            .collection('Tasks')
            .doc(task.id)
            .update({'completed': completed});
      }
    } catch (e) {
      print('Error updating task completion status: $e');
    }
  }

  Future<List<Task>> getIncompleteTasksForToday() async {
    // Get the current date without the time part
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    // Get the end of the day (11:59:59.999)
    DateTime endOfDay =
        today.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userId', isEqualTo: _user!.uid)
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: endOfDay)
          .where('completed', isEqualTo: false)
          .get();

      // Parse the retrieved data into a list of Task objects
      List<Task> tasks = querySnapshot.docs.map((doc) {
        return Task.fromJson(doc.data() as Map<String, dynamic>)..id = doc.id;
      }).toList();

      // Include incomplete repeating tasks from the past
      QuerySnapshot repeatingTasksSnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userId', isEqualTo: _user!.uid)
          .where('repeating', isEqualTo: true)
          .where('completed', isEqualTo: false)
          .get();

      List<Task> repeatingTasks = repeatingTasksSnapshot.docs
          .map((doc) {
            return Task.fromJson(doc.data() as Map<String, dynamic>)
              ..id = doc.id;
          })
          .where((task) => !tasks.contains(task))
          .toList();

      tasks.addAll(repeatingTasks);

      print("tasks:");
      print(tasks);
      return tasks;
    } catch (e) {
      print('Error fetching incomplete tasks for today: $e');
      return [];
    }
  }

  Future<void> _taskCompleted() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/completed.mp3');
      final data = await rootBundle.load('assets/complete.mp3');
      await file.writeAsBytes(data.buffer.asUint8List());
      await audioPlayer.play(UrlSource(file.path));
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
