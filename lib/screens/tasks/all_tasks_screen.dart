import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:TaskWhiz/widget/tasksFilter/repeating_task_widget.dart';
import 'package:TaskWhiz/widget/tasksFilter/normal_task_widget.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({Key? key}) : super(key: key);

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  String _selectedTaskType = 'Normal'; // Default to show Normal tasks

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Task Type',
              border: OutlineInputBorder(),
            ),
            value: _selectedTaskType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTaskType = newValue!;
              });
            },
            items: [
              'Normal',
              'Daily',
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday',
              'Sunday',
              'Weekend'
            ].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          SizedBox(height: 16.0),
          Expanded(
            // Wrap with Expanded to take the remaining space
            child: _selectedTaskType == 'Normal'
                ? NormalTasksWidget()
                : RepeatingTasksWidget(type: _selectedTaskType),
          ),
        ],
      ),
    );
  }
}
