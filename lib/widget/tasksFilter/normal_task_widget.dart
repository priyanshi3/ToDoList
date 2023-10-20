import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:TaskWhiz/screens/add_task_screen.dart';

class NormalTasksWidget extends StatefulWidget {
  const NormalTasksWidget({super.key});

  @override
  State<NormalTasksWidget> createState() => _NormalTasksWidgetState();
}

class _NormalTasksWidgetState extends State<NormalTasksWidget> {
  late User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<List<Task>>(
      future: getIncompleteTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No tasks.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Task task = snapshot.data![index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  color: Colors.red,
                  iconSize: 24.0,
                  onPressed: () {
                    _deleteTask(task.id);
                  },
                ),
              );
            },
          );
        }
      },
    ));
  }

  Future<List<Task>> getIncompleteTasks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tasks')
          .where('userId', isEqualTo: _user!.uid)
          .where('repeating', isEqualTo: false)
          .where('completed', isEqualTo: false)
          .get();
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

  Future<void> _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance.collection('Tasks').doc(taskId).delete();

      setState(() {});
    } catch (e) {
      print('Error deleting task: $e');
    }
  }
}
