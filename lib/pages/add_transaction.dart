import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import '../models/task_model.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _taskDetailController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCategory;
  String? _selectedPriority;

  final List<String> _categories = ["Work", "Study", "Exercise"];
  final List<String> _priorities = ["High", "Medium", "Low"];

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveTask() async {
    if (_taskNameController.text.isEmpty ||
        _taskDetailController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null ||
        _selectedCategory == null ||
        _selectedPriority == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final task = TaskModel(
      title: _taskNameController.text,
      details: _taskDetailController.text,
      date: DateFormat.yMd().format(_selectedDate!),
      time: _selectedTime!.format(context),
      category: _selectedCategory!,
      priority: _selectedPriority!,
    );

    final box = Hive.box<TaskModel>('tasksBox');
    await box.add(task);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task berhasil ditambahkan")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _taskDetailController,
              decoration: const InputDecoration(labelText: 'Task Details'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedDate == null
                    ? 'No Date Chosen!'
                    : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}'),
                TextButton(
                    onPressed: () => _selectDate(context),
                    child: const Text('Choose Date')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedTime == null
                    ? 'No Time Chosen!'
                    : 'Picked Time: ${_selectedTime!.format(context)}'),
                TextButton(
                    onPressed: () => _selectTime(context),
                    child: const Text('Choose Time')),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Select Category"),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              hint: const Text("Select Priority"),
              items: _priorities.map((priority) {
                return DropdownMenuItem(value: priority, child: Text(priority));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Priority'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveTask, child: const Text('Add Task')),
          ],
        ),
      ),
    );
  }
}
