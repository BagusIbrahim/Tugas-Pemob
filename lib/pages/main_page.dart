import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/task_model.dart';
import '../pages/add_transaction.dart';
import '../pages/home_page.dart';
import '../pages/analityc.dart';
import '../providers/theme_provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime selectedDate = DateTime.now();
  final taskBox = Hive.box<TaskModel>('tasksBox');

  void _addTask(TaskModel task) async {
    await taskBox.add(task);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil disimpan')),
    );
    setState(() {});
  }

  void _updateTask(int index, TaskModel updatedTask) async {
    await taskBox.putAt(index, updatedTask);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil diperbarui')),
    );
    setState(() {});
  }

  void _deleteTask(int index) async {
    await taskBox.deleteAt(index);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task berhasil dihapus')),
    );
    setState(() {});
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            child: const Text('Keluar'),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // keluar dari MainPage
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            SwitchListTile(
              title: const Text("Tema Gelap"),
              secondary: const Icon(Icons.dark_mode),
              value: themeProvider.isDarkMode,
              onChanged: (val) => themeProvider.toggleTheme(val),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Keluar'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.of(context).push<TaskModel>(
            MaterialPageRoute(builder: (_) => const TransactionPage()),
          );

          if (newTask != null) _addTask(newTask);
        },
        backgroundColor: Theme.of(context).primaryColorLight,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CalendarAppBar(
            accent: Theme.of(context).primaryColor,
            backButton: false,
            onDateChanged: (value) {
              setState(() {
                selectedDate = value;
              });
            },
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now(),
          ),
          Expanded(
            child: HomePage(
              selectedDate: selectedDate,
              onTaskUpdate: _updateTask,
              onTaskDelete: _deleteTask,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.home, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 40),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AnalitycPage()),
                );
              },
              icon:
                  Icon(Icons.analytics, color: Theme.of(context).primaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
