import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/add_task_screen.dart';

class DailySchedule extends StatefulWidget {
  const DailySchedule({Key? key}) : super(key: key);

  @override
  State<DailySchedule> createState() => _DailyScheduleState();
}

class _DailyScheduleState extends State<DailySchedule> {
  late User? _user = FirebaseAuth.instance.currentUser;

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
                  title: Text(task.title),
                  subtitle: Text(task.description),
                  trailing: Checkbox(
                    value: task.completed,
                    onChanged: (bool? value) async {
                      await updateTaskCompletionStatus(task.id, value ?? false);
                      setState(() {});
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

  Future<void> updateTaskCompletionStatus(String taskId, bool completed) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tasks')
          .doc(taskId)
          .update({'completed': completed});
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
      print("tasks:");
      print(tasks);
      return tasks;
    } catch (e) {
      print('Error fetching incomplete tasks for today: $e');
      return [];
    }
  }
}
