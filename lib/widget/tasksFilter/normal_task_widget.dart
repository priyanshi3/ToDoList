import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:TaskWhiz/screens/tasks/add_task_screen.dart';
import 'package:intl/intl.dart';

class NormalTasksWidget extends StatefulWidget {
  const NormalTasksWidget({super.key});

  @override
  State<NormalTasksWidget> createState() => _NormalTasksWidgetState();
}

class _NormalTasksWidgetState extends State<NormalTasksWidget> {
  late User? _user = FirebaseAuth.instance.currentUser;
  AudioPlayer audioPlayer = AudioPlayer();

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
                String formattedDate =
                    DateFormat.yMd().format(task.date.toLocal());

                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 18.0, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // Make the font bold
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14.0, // Adjust the font size as needed
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontStyle: FontStyle.italic, // Make the font italic
                          fontWeight: FontWeight.w300, // Make the font thin
                          fontSize: 12.0, // Adjust the font size as needed
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    color: Colors.red,
                    iconSize: 24.0,
                    onPressed: () {
                      _deleteTask(task.id);
                      _taskDeleted();
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

  Future<void> _taskDeleted() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/delete.mp3');
      final data = await rootBundle.load('assets/delete.mp3');
      await file.writeAsBytes(data.buffer.asUint8List());
      await audioPlayer.play(UrlSource(file.path));
    } catch (e) {
      print(e);
    }
  }
}
