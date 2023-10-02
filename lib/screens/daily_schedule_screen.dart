import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login/screens/add_task_screen.dart';

class DailySchedule extends StatefulWidget {
  const DailySchedule({super.key});

  @override
  State<DailySchedule> createState() => _DailyScheduleState();
}

class _DailyScheduleState extends State<DailySchedule> {
  late User? _user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Task>>(
        future: getTasksForToday(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No tasks for today.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Task task = snapshot.data![index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Checkbox(
                    value: task.completed,
                    onChanged: (bool? value) {
                      // Update the task as completed in your data source
                      // You might have a method like updateTaskCompletionStatus(task.id, value)
                      // and then call setState to update the UI
                      setState(() {
                        task.completed = value!;
                      });
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<Task>> getTasksForToday() async {
    // Get the current date without the time part
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    try {
      // Query Firestore for tasks with a date equal to today
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userId',
              isEqualTo: _user!.uid) // Assuming each task has a userId field
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: today.add(Duration(days: 1)))
          .get();

      // Parse the retrieved data into a list of Task objects
      List<Task> tasks = querySnapshot.docs.map((doc) {
        return Task.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return tasks;
    } catch (e) {
      // Handle any errors that might occur during the data fetching
      print('Error fetching tasks for today: $e');
      return [];
    }
  }
}
