import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widget/new_widget.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            'TaskWhiz',
            style: TextStyle(
                fontFamily: 'Kablammo',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red.shade800,
          actions: <Widget>[
            //add new task
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 5, 10),
              child: FloatingActionButton(
                heroTag: "AddTask",
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => NewWidget()));
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.tealAccent,
                mini: true,
              ),
            ),
            //logout
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 10, 10, 10),
              child: FloatingActionButton(
                heroTag: "SignOut",
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: Icon(Icons.logout),
                backgroundColor: Colors.tealAccent,
                mini: true,
              ),
            ),
          ]),
      body: StreamBuilder<List<Task>>(
          stream: readTasks(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong! ${snapshot.error}');
            } else if (snapshot.hasData) {
              final tasks = snapshot.data!;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.count(
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: tasks.map(buildTask).toList(),
                  ),
                ),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }

  Widget buildTask(Task task) => GestureDetector(
      child: Container(
          child: Card(
        elevation: 10,
        color: Colors.white38,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                      ),
                    ),
                    if (task.repeating)
                      Icon(
                        Icons.event_repeat,
                        size: 25,
                      )
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Divider(
                  color: Colors.white,
                  thickness: 2,
                ),
                SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      task.description,
                      style: TextStyle(fontSize: 23),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                if (!task.repeating)
                  Expanded(
                    child: Center(
                      child: Text(
                        DateFormat("dd-MM-yyyy").format(task.date),
                        style: TextStyle(fontSize: 23),
                      ),
                    ),
                  ),
                if (task.repeating)
                  Expanded(
                      child: Center(
                    child: Text(
                      task.repeatOn,
                      style: TextStyle(fontSize: 23),
                    ),
                  ))
              ],
            ),
          ),
        ),
      )),
      onTap: () {
        // showDialog(
        //   builder: (BuildContext context) => _showTask(context),
        //   context: context,
        // );
      });

  Widget _showTask(BuildContext context) {
    return new AlertDialog(
      title: const Text('Popup example'),
      content: new Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text("Hello"),
        ],
      ),
      actions: <Widget>[
        new ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  Stream<List<Task>> readTasks() => FirebaseFirestore.instance
      .collection('tasks')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList());
}
