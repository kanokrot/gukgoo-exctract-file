import 'package:flutter/material.dart';
import 'package:gukgoo/pages/screens/chat_screen.dart';
import 'package:gukgoo/pages/screens/notification_page.dart';
import 'package:gukgoo/pages/screens/profile.dart';
import 'package:gukgoo/pages/screens/friend.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file exists and is set up correctly

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions.currentPlatform, // สำหรับ Web ให้ใส่ options
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // กำหนดหน้าแต่ละหน้า
    _pages = [
      ChatApp(), // หน้าแชท
      NotificationPage(
        onThemeChanged: _toggleTheme,
        isDarkMode: _isDarkMode,
      ), // หน้าการแจ้งเตือน พร้อมการเปลี่ยนธีม
      FriendsListPage(), // หน้ารายชื่อเพื่อน
      ProfileScreen(
          username: 'Your Username'), // หน้าโปรไฟล์ (แทนด้วยชื่อของคุณ)
    ];
  }

  // ฟังก์ชันจัดการการกดที่ Bottom Navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // ฟังก์ชันจัดการการเปลี่ยนธีม
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      // อัปเดต NotificationPage เมื่อมีการเปลี่ยนธีม
      _pages[1] = NotificationPage(
        onThemeChanged: _toggleTheme,
        isDarkMode: _isDarkMode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            ['Chat', 'Notifications', 'Friends', 'Profile'][_selectedIndex],
          ),
        ),
        body: _pages[_selectedIndex], // แสดงหน้าที่เลือกจาก _selectedIndex
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Friends',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
