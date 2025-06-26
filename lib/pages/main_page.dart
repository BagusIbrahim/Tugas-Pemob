import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:tugasanalisis/pages/add_transaction.dart';
import 'package:tugasanalisis/pages/home_page.dart';
import 'package:tugasanalisis/pages/analityc.dart';
import '../pages/auth_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  DateTime selectedDate = DateTime.now();

  // Fungsi logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          FilledButton(
            child: const Text('Logout'),
            onPressed: () {
              Navigator.of(ctx).pop();
              _logout();
            },
          ),
        ],
      ),
    );
  }

  // Fungsi untuk simpan task ke Firestore
  Future<void> _addTask(Map<String, String> task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(user.uid)
          .collection('user_tasks')
          .add({
        'title': task['title'],
        'details': task['details'],
        'date': task['date'],
        'time': task['time'],
        'category': task['category'],
        'priority': task['priority'],
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task berhasil disimpan ke Firebase')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan task: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
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
          final newTask = await Navigator.of(context).push<Map<String, String>>(
            MaterialPageRoute(builder: (context) => const TransactionPage()),
          );

          if (newTask != null) {
            await _addTask(newTask);
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          CalendarAppBar(
            accent: Colors.teal,
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
              onTaskUpdate:
                  (String docId, Map<String, String> updatedTask) async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                try {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(user.uid)
                      .collection('user_tasks')
                      .doc(docId)
                      .update(updatedTask);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task berhasil diperbarui')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update task: $e')),
                  );
                }
              },
              onTaskDelete: (String docId) async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) return;

                try {
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(user.uid)
                      .collection('user_tasks')
                      .doc(docId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task berhasil dihapus')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal hapus task: $e')),
                  );
                }
              },
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
              icon: const Icon(Icons.home, color: Colors.teal),
            ),
            const SizedBox(width: 40),
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AnalitycPage()),
                );
              },
              icon: const Icon(Icons.analytics, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
