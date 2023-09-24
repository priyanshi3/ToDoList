
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login/palette.dart';

import '../main.dart';
import '../page/forgot_password_page.dart';
import '../utils.dart';

class NewWidget extends StatefulWidget {
  // final VoidCallback? onRepeatSelected;

  const NewWidget({
    Key? key,
    // required this.onRepeatSelected,
  }) : super(key: key);

  @override
  _NewWidgetState createState() => _NewWidgetState();

}

class _NewWidgetState extends State<NewWidget> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final dateController = TextEditingController();
  bool repeatController = false;

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
          SizedBox(height: 60,),
          Text(
            'Add New Task',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 40,),
          TextField(
            controller: titleController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 4,),
          TextField(
            controller: descriptionController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          SizedBox(height: 4,),
          TextField(
            controller: dateController,
            cursorColor: Colors.white,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              icon: Icon(Icons.calendar_today),
              labelText: 'Date',
            ),
            readOnly: true,
            onTap: () => selectdate(context),
          ),
          SizedBox(height: 4,),
          Row(
            children: <Widget>[
              SizedBox(
                width: 10,
              ), //SizedBox
              Text(
                'Repeat ',
                style: TextStyle(fontSize: 17.0),
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
          SizedBox(height: 30,),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50)
            ),
            icon: Icon(Icons.task_alt, size: 32,),
            label: Text(
              'Add Task',
              style: TextStyle(fontSize: 24),
            ),
            onPressed: addTask,
          ),
        ],
      ),
    ),
  );

  Future addTask() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator(),)
    );

    try {
      final newtask = FirebaseFirestore.instance.collection('tasks').doc();
      final task = Task(
        id: newtask.id,
        title: titleController.text,
        description: descriptionController.text,
        date: DateTime.parse(dateController.text),
        repeating: repeatController,
      );
      final json = task.toJson();
      // final json = {
      //   'title' : titleController.text,
      //   'description' : descriptionController.text,
      //   'date' : dateController.text,
      //   'repeating' : repeatController,
      // };
      //write to firebase
      await newtask.set(json);
      print(json);

    }
    on FirebaseFirestore catch (e) {
      print(e);

      // Utils.showSnackBar(e);
    }
    navigatorKey.currentState!.popUntil((route) => route.isFirst);
  }

  Future<void> selectdate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2300)
    );
    if(pickedDate != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      setState(() {
        dateController.text = formattedDate; //set output date to TextField value.
      });
    }
  }
}

class Task {
  String id;
  final String title;
  final String description;
  final DateTime date;
  final bool repeating;

  Task({
    this.id = '',
    required this.title,
    required this.description,
    required this.date,
    required this.repeating
  });

  Map<String, dynamic> toJson() => {
    'title' : title,
    'description' : description,
    'date' : date,
    'repeating' : repeating,
  };

  static Task fromJson(Map<String, dynamic> json) => Task (
    // id: json['id'],
    title: json['title'],
    description: json['description'],
    date: json['date'].toDate(),
    repeating: json['repeating']
  );
}
