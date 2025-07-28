import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task_model.dart';

class HomePage extends StatelessWidget {
  final Function(int, TaskModel) onTaskUpdate;
  final Function(int) onTaskDelete;
  final DateTime selectedDate;

  const HomePage({
    super.key,
    required this.onTaskUpdate,
    required this.onTaskDelete,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final taskBox = Hive.box<TaskModel>('tasksBox');

    return ValueListenableBuilder(
      valueListenable: taskBox.listenable(),
      builder: (context, Box<TaskModel> box, _) {
        final tasks = box.values.toList();
        final filteredTasks = tasks
            .asMap()
            .entries
            .where((entry) =>
                entry.value.date.year == selectedDate.year &&
                entry.value.date.month == selectedDate.month &&
                entry.value.date.day == selectedDate.day)
            .toList()
          ..sort(
              (a, b) => a.value.time.compareTo(b.value.time)); // Sort by time

        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Your Task Manager",
                    style: GoogleFonts.montserrat(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Tasks on ${selectedDate.toLocal().toString().split(' ')[0]}",
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (filteredTasks.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        "No tasks yet!",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ...filteredTasks.map((entry) {
                  final index = entry.key;
                  final task = entry.value;

                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          title: Text(
                            task.title,
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("📌 Details: ${task.details}"),
                              Text(
                                  "📅 Date: ${task.date.toLocal().toString().split(' ')[0]} at ${task.time}"),
                              Text("📂 Category: ${task.category}"),
                              Text("⚡ Priority: ${task.priority}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditDialog(context, index, task);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  onTaskDelete(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index, TaskModel task) {
    final titleController = TextEditingController(text: task.title);
    final detailsController = TextEditingController(text: task.details);
    DateTime selectedDate = task.date as DateTime;
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(task.time.split(":")[0]),
      minute: int.parse(task.time.split(":")[1]),
    );

    String selectedCategory = task.category;
    String selectedPriority = task.priority;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Task"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(labelText: "Details"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: Text(
                          "Pick Date: ${selectedDate.toLocal().toString().split(' ')[0]}"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );
                        if (picked != null) {
                          setState(() => selectedTime = picked);
                        }
                      },
                      child: Text("Pick Time: ${selectedTime.format(context)}"),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: ['Work', 'Study', 'Personal', 'Other']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedCategory = val!),
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ['High', 'Medium', 'Low']
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedPriority = val!),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    final updatedTask = TaskModel(
                      title: titleController.text,
                      details: detailsController.text,
                      date: selectedDate.toIso8601String(),
                      time:
                          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}",
                      category: selectedCategory,
                      priority: selectedPriority,
                    );
                    onTaskUpdate(index, updatedTask);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

extension on String {
  get year => null;

  get month => null;

  get day => null;

  toLocal() {}
}
