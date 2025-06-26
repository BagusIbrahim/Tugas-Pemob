import 'package:flutter/material.dart';
import 'package:calendar_appbar/calendar_appbar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Impor Firebase Auth

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
  // State untuk menyimpan daftar tugas/transaksi
  List<Map<String, String>> tasks = [];

  // Fungsi untuk menambahkan tugas baru ke dalam list
  void _addTask(Map<String, String> task) {
    setState(() {
      tasks.add(task);
    });
  }

  // Fungsi untuk memperbarui tugas yang sudah ada
  void _updateTask(int index, Map<String, String> updatedTask) {
    setState(() {
      tasks[index] = updatedTask;
    });
  }

  // Fungsi untuk menghapus tugas
  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  // --- FUNGSI LOGOUT BARU ---
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // Kembali ke halaman login setelah logout
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }
  
  // Fungsi untuk menampilkan dialog konfirmasi logout
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
              Navigator.of(ctx).pop(); // Tutup dialog
              _logout(); // Panggil fungsi logout
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // DIUBAH: Mengganti CalendarAppBar dengan AppBar standar untuk menambahkan menu drawer
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: Colors.teal,
        // Properti actions tidak lagi dibutuhkan di sini
      ),
      // DITAMBAHKAN: Drawer untuk menu samping
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                _showLogoutDialog(); // Tampilkan dialog konfirmasi
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTask = await Navigator.of(context).push<Map<String, String>>(
            MaterialPageRoute(
              builder: (context) => TransactionPage(),
            ),
          );

          if (newTask != null) {
            _addTask(newTask);
          }
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      // DIUBAH: Membungkus body dengan Column untuk menambahkan CalendarAppBar
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
              tasks: tasks,
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
              onPressed: () {
                // Tidak melakukan apa-apa karena sudah di halaman utama
              },
              icon: const Icon(Icons.home, color: Colors.teal),
            ),
            const SizedBox(width: 40), 
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AnalitycPage(),
                ));
              },
              icon: const Icon(Icons.analytics, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}