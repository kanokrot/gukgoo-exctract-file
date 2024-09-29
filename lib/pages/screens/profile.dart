import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'friend.dart'; // นำเข้าหน้ารายชื่อเพื่อน
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Authentication

class ProfileScreen extends StatefulWidget {
  final String username;

  const ProfileScreen({Key? key, required this.username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  TextEditingController _noteController = TextEditingController();

  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
    });
  }

  // ฟังก์ชันเลือกภาพ
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // ฟังก์ชัน Logout
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context)
        .pushReplacementNamed('/login'); // กลับไปหน้า Login หลังจาก logout
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ปิดการแสดงปุ่มย้อนกลับใน AppBar
        title: Text('Profile: ${widget.username}'),
        actions: [
          // ปุ่มสำหรับไปหน้ารายชื่อเพื่อน
          IconButton(
            icon: Icon(Icons.group),
            onPressed: () {
              // นำทางไปยังหน้ารายชื่อเพื่อน
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendsListPage(),
                ),
              );
            },
          ),
          // ปุ่ม Logout
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(); // เรียกใช้ฟังก์ชัน logout
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // พื้นหลังสีชมพูที่ครึ่งบน
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: const Color.fromARGB(255, 15, 6, 8),
              height: MediaQuery.of(context).size.height * 0.7,
            ),
          ),
          Positioned(
            top: 20,
            left: 25,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // กรอบวงกลมสีชมพู
                Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 9, 3, 4),
                  ),
                ),
                // รูปโปรไฟล์
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                // Feather icon สำหรับอัพโหลดรูป
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.create, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // เลื่อนตำแหน่งชื่อให้สูงขึ้น
          Positioned(
            top: 160,
            left: 40,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงชื่อผู้ใช้
                Text(
                  'Name: ${currentUser?.displayName ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // แสดงอีเมล
                Text(
                  'Email: ${currentUser?.email ?? 'N/A'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 160), // เว้นระยะห่างเพิ่มเติม
                // กล่องโน้ต
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 252, 253),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Note',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white, // สีพื้นหลังหลักเป็นสีขาว
    );
  }
}
