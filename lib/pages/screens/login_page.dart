import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class LoginPage extends StatelessWidget {
  final Function onThemeChanged; // ฟังก์ชันสำหรับเปลี่ยนธีม
  final bool isDarkMode; // เช็คสถานะว่ากำลังใช้ Dark Mode อยู่หรือไม่

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // ฟังก์ชันสำหรับการเข้าสู่ระบบและบันทึกข้อมูลผู้ใช้ลง Firestore
  Future<void> signInWithEmailAndPassword(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // เมื่อเข้าสู่ระบบสำเร็จ จะบันทึกข้อมูลผู้ใช้ลงใน Firestore
      await saveUserToFirestore(userCredential.user);

      // เมื่อเข้าสู่ระบบสำเร็จ จะเปลี่ยนเส้นทางไปที่ ChatApp
      Navigator.pushNamed(context, '/chat');
    } on FirebaseAuthException catch (e) {
      // Handle errors ที่เกิดจากการ Authentication
      String errorMessage = 'An error occurred';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  // ฟังก์ชันบันทึกข้อมูลผู้ใช้ลง Firestore
  Future<void> saveUserToFirestore(User? user) async {
    if (user == null) return;

    // อ้างอิงไปที่ collection 'users' ใน Firestore
    CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('users');

    // ตรวจสอบว่าผู้ใช้มีข้อมูลอยู่แล้วหรือยัง
    final userDoc = await usersCollection.doc(user.uid).get();

    if (!userDoc.exists) {
      // บันทึกข้อมูลผู้ใช้ใหม่
      await usersCollection.doc(user.uid).set({
        'userId': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '', // ถ้ามี displayName
        'photoURL': user.photoURL ?? '', // ถ้ามี photoURL
        'lastSignIn': FieldValue.serverTimestamp(), // เวลาที่เข้าสู่ระบบล่าสุด
      });
    } else {
      // อัปเดตเวลาที่เข้าสู่ระบบล่าสุด
      await usersCollection.doc(user.uid).update({
        'lastSignIn': FieldValue.serverTimestamp(),
      });
    }
  }

  LoginPage({required this.onThemeChanged, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login Page'),
        actions: [
          // สวิตช์สำหรับเปลี่ยนธีม
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              onThemeChanged(); // เรียกฟังก์ชันเพื่อเปลี่ยนธีม
            },
          ),
        ],
      ),
      backgroundColor:
          isDarkMode ? Colors.black : Colors.white, // เปลี่ยนสีพื้นหลังตามธีม
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // โลโก้ของแอป จะเปลี่ยนไปตามธีม
              Image.asset(
                isDarkMode
                    ? 'assets/images/logo2.png' // โลโก้สำหรับ Dark Mode
                    : 'assets/images/logo.png', // โลโก้สำหรับ Light Mode
                height: 150,
              ),
              SizedBox(height: 20),
              // ช่องสำหรับ Email
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[300], // เปลี่ยนสีตามธีม
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email,
                        color: isDarkMode ? Colors.white : Colors.black),
                    hintText: 'Email',
                    hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              SizedBox(height: 20),
              // ช่องสำหรับ Password
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock,
                        color: isDarkMode ? Colors.white : Colors.black),
                    hintText: 'Password',
                    hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              SizedBox(height: 20),
              // ปุ่ม Login
              ElevatedButton(
                onPressed: () async {
                  // เรียกใช้ฟังก์ชันการเข้าสู่ระบบ
                  await signInWithEmailAndPassword(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.white : Colors.black,
                  foregroundColor: isDarkMode ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 20),
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // ปุ่มไปหน้า Register
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                      context, '/register'); // นำทางไปยังหน้า RegistrationPage
                },
                child: Text(
                  'Don\'t have an account? Register here',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
