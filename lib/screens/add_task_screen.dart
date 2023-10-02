import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    Key? key,
  }) : super(key: key);

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late User? _user = FirebaseAuth.instance.currentUser;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  bool repeatController = false;
  var repeatOnValue = "Daily";

  final items = [
    "Daily",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
    "Weekend"
  ];

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    dateController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 60,
              ),
              Text(
                'Add New Task',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'SofiaSans',
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextField(
                controller: titleController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontFamily: 'SofiaSans',
                ),
                decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(
                      fontFamily: 'SofiaSans',
                    )),
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                controller: descriptionController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontFamily: 'SofiaSans',
                ),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(
                    fontFamily: 'SofiaSans',
                  ),
                ),
              ),
              SizedBox(
                height: 4,
              ),
              TextField(
                controller: dateController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.next,
                style: TextStyle(
                  fontFamily: 'SofiaSans',
                ),
                decoration: InputDecoration(
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Date',
                  iconColor: Colors.white,
                  labelStyle: TextStyle(
                    fontFamily: 'SofiaSans',
                  ),
                ),
                readOnly: true,
                onTap: () => selectdate(context),
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 10,
                  ), //SizedBox
                  Text(
                    'Repeat ',
                    style: TextStyle(fontSize: 17.0, fontFamily: 'SofiaSans'),
                  ), //Text
                  SizedBox(width: 10), //SizedBox
                  /** Checkbox Widget **/
                  Checkbox(
                    value: repeatController,
                    onChanged: (bool? value) {
                      setState(() {
                        repeatController = value!;
                      });
                    },
                  ), //Checkbox
                ], //<Widget>[]
              ),
              SizedBox(
                height: 10,
              ),
              if (repeatController)
                DropdownButton(
                    value: repeatOnValue,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconEnabledColor: Colors.white,
                    items: items.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style: TextStyle(fontFamily: 'SofiaSans'),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        repeatOnValue = value!;
                      });
                    }),
              SizedBox(
                height: 30,
              ),
              ElevatedButton.icon(
                style:
                    ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
                icon: Icon(
                  Icons.task_alt,
                  size: 32,
                ),
                label: Text(
                  'Add Task',
                  style: TextStyle(fontSize: 24, fontFamily: 'SofiaSans'),
                ),
                onPressed: addTask,
              ),
            ],
          ),
        ),
      );

  Future<void> selectdate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2300));
    if (pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        dateController.text = formattedDate;
        // Reset the repeatOnValue when selecting a new date
        repeatOnValue = "Daily";
      });
    }
  }

  Future addTask() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final newtask = FirebaseFirestore.instance.collection('Tasks').doc();
      final task = Task(
        id: newtask.id,
        userId: _user!.uid,
        title: titleController.text,
        description: descriptionController.text,
        date: DateTime.parse(dateController.text),
        repeating: repeatController,
        repeatOn: repeatOnValue,
      );
      final json = task.toJson();

      await newtask.set(json);
      print('Task added successfully: $json');

      // If task is repeating, and it's completed, add the next instance
      if (repeatController && !task.completed) {
        await addNextRepeatingTask(task);
      }
    } catch (e) {
      print('Error adding task: $e');
    }

    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future<void> addNextRepeatingTask(Task task) async {
    DateTime calculateNextDate(DateTime currentDate, String repeatOn) {
      // For simplicity, let's add one day to the current date
      return currentDate.add(Duration(days: 1));
    }

    // Calculate the next date based on the repeatOnValue
    DateTime nextDate = calculateNextDate(task.date, task.repeatOn);

    // Create a new task with the same details but the new date
    final nextTask = Task(
      userId: task.userId,
      title: task.title,
      description: task.description,
      date: nextDate,
      repeating: task.repeating,
      repeatOn: task.repeatOn,
    );

    final json = nextTask.toJson();

    try {
      final newTaskDoc =
          await FirebaseFirestore.instance.collection('Tasks').add(json);
      print('Next repeating task added successfully: $json');
    } catch (e) {
      print('Error adding next repeating task: $e');
    }
  }
}

class Task {
  bool completed;

  String id;
  final String userId;
  final String title;
  final String description;
  final DateTime date;
  final bool repeating;
  final String repeatOn;

  Task({
    this.id = '',
    required this.userId,
    required this.title,
    required this.description,
    required this.date,
    this.repeating = false,
    this.repeatOn = "One Time",
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'title': title,
        'description': description,
        'date': date,
        'repeating': repeating,
        'repeatOn': repeatOn,
        'completed': completed,
      };

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] != null
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      repeating: json['repeating'] ?? false,
      repeatOn: json['repeatOn'] ?? 'Daily',
      completed: json['completed'] ?? false,
    );
  }
}
