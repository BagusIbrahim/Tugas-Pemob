// Lokasi File: lib/services/auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemUiOverlayStyle
import 'main_page.dart'; // Pastikan file ini ada di folder yang sama (lib/services)

// Impor package Firebase yang diperlukan
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // GlobalKey untuk mengelola state dan validasi dari Form.
  final _formKey = GlobalKey<FormState>();

  // Instance dari Firebase Auth untuk menangani proses autentikasi.
  final _firebaseAuth = FirebaseAuth.instance;

  // State untuk UI
  var _isLoginMode = true; // true untuk Login, false untuk Register
  var _isLoading = false;

  // Variabel untuk menampung input pengguna
  String _enteredEmail = '';
  String _enteredPassword = '';
  String _enteredFullName = '';

  /// Beralih antara mode Login dan Register.
  void _toggleFormMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _formKey.currentState?.reset(); // Membersihkan error validasi sebelumnya
    });
  }

  /// Fungsi untuk mengirimkan form, baik untuk login maupun registrasi.
  Future<void> _submitForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid == null || !isValid) {
      return; // Jika form tidak valid, hentikan proses
    }
    _formKey.currentState?.save(); // Panggil onSaved pada semua TextFormField

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLoginMode) {
        // --- LOGIKA LOGIN ---
        await _firebaseAuth.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        // --- LOGIKA REGISTER ---
        final userCredentials =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        // Simpan data tambahan (nama lengkap) ke Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'namaLengkap': _enteredFullName,
          'email': _enteredEmail,
          'createdAt': Timestamp.now(), // Simpan waktu pembuatan akun
        });
      }

      // Jika berhasil, navigasi ke MainPage
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const MainPage()),
        );
      }
    } on FirebaseAuthException catch (error) {
      // Menangani error spesifik dari Firebase Auth
      var errorMessage = 'Terjadi kesalahan autentikasi.';
      if (error.code == 'email-already-in-use') {
        errorMessage = 'Alamat email ini sudah terdaftar.';
      } else if (error.code == 'invalid-email') {
        errorMessage = 'Alamat email tidak valid.';
      } else if (error.code == 'weak-password') {
        errorMessage = 'Kata sandi terlalu lemah.';
      } else if (error.code == 'user-not-found' ||
          error.code == 'wrong-password' ||
          error.code == 'invalid-credential') {
        errorMessage = 'Email atau kata sandi yang Anda masukkan salah.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (error) {
      // Menangani error umum lainnya
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Terjadi kesalahan yang tidak diketahui. Coba lagi nanti.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper function untuk membuat dekorasi input yang konsisten
    InputDecoration buildInputDecoration(String labelText, IconData icon) {
      return InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.white70),
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.yellowAccent.shade700, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.yellowAccent.shade700, width: 1.5),
        ),
        errorStyle: TextStyle(
            color: Colors.yellowAccent.shade700, fontWeight: FontWeight.bold),
      );
    }

    // Mengatur warna status bar menjadi terang agar kontras dengan background gelap
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: Container(
        // Latar belakang dengan gradien untuk tampilan yang lebih menarik
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade900, Colors.teal.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Bagian Header
                    const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isLoginMode ? 'Selamat Datang' : 'Buat Akun Baru',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLoginMode
                          ? 'Masuk untuk mengelola waktumu'
                          : 'Isi data untuk memulai',
                      style: TextStyle(
                          fontSize: 16, color: Colors.white.withOpacity(0.8)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Input field untuk Nama Lengkap (hanya tampil saat mode Register)
                    if (!_isLoginMode)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: TextFormField(
                          decoration: buildInputDecoration(
                              'Nama Lengkap', Icons.person_outline),
                          style: const TextStyle(color: Colors.white),
                          enableSuggestions: false,
                          validator: (value) {
                            if (value == null || value.trim().length < 3) {
                              return 'Nama lengkap minimal 3 karakter';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredFullName = value!;
                          },
                        ),
                      ),

                    // Input field untuk Email
                    TextFormField(
                      decoration:
                          buildInputDecoration('Email', Icons.email_outlined),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      validator: (value) {
                        if (value == null ||
                            !value.contains('@') ||
                            !value.contains('.')) {
                          return 'Masukkan alamat email yang valid';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredEmail = value!;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input field untuk Kata Sandi
                    TextFormField(
                      decoration: buildInputDecoration(
                          'Kata Sandi', Icons.lock_outline),
                      style: const TextStyle(color: Colors.white),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.length < 6) {
                          return 'Kata sandi minimal harus 6 karakter';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredPassword = value!;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input field untuk Konfirmasi Kata Sandi (hanya tampil saat mode Register)
                    if (!_isLoginMode)
                      TextFormField(
                        decoration: buildInputDecoration(
                            'Konfirmasi Kata Sandi',
                            Icons.lock_person_outlined),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          _formKey.currentState
                              ?.save(); // Simpan form untuk dapat _enteredPassword
                          if (value != _enteredPassword) {
                            return 'Kata sandi tidak cocok';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 30),

                    // Tombol utama dengan efek bayangan dan gaya modern
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.4),
                      ),
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.teal.shade800)),
                            )
                          : Text(
                              _isLoginMode ? 'MASUK' : 'DAFTAR',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 1),
                            ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol untuk beralih mode
                    if (!_isLoading)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoginMode
                                ? 'Belum punya akun?'
                                : 'Sudah punya akun?',
                            style:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                          ),
                          TextButton(
                            onPressed: _toggleFormMode,
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                            child: Text(
                              _isLoginMode ? 'Daftar di sini' : 'Masuk di sini',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
