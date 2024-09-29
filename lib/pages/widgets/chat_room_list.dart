import 'dart:math'; // Import สำหรับการสุ่ม roomId
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomList extends StatelessWidget {
  final List<Map<String, dynamic>> chatRooms;
  final Function(String, String) onSelectChatRoom;
  final String selectedChatRoomId;

  const ChatRoomList({
    required this.chatRooms,
    required this.onSelectChatRoom,
    required this.selectedChatRoomId,
  });

  // ฟังก์ชันสร้างห้องแชทใหม่
  void _createChatRoom(BuildContext context) {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseAuth _auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? roomName;
        String? roomPassword;

        return AlertDialog(
          title: Text('Create Chat Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Room Name'),
                onChanged: (value) {
                  roomName = value.trim();
                },
              ),
              TextField(
                decoration: InputDecoration(hintText: 'Room Password'),
                obscureText: true, // ปิดบังรหัสผ่าน
                onChanged: (value) {
                  roomPassword = value.trim();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (roomName != null &&
                    roomName!.isNotEmpty &&
                    roomPassword != null &&
                    roomPassword!.isNotEmpty) {
                  String userId = _auth.currentUser!.uid;
                  String roomId = _generateRoomId(); // สร้าง roomId แบบสุ่ม

                  // สร้าง Document ใหม่ใน collection ของ chatRooms
                  await _firestore.collection('chatRooms').doc(roomId).set({
                    'name': roomName,
                    'password': roomPassword,
                    'createdBy': userId,
                    'createdAt': FieldValue.serverTimestamp(),
                    'roomId': roomId,
                  });

                  Navigator.pop(context); // ปิด Dialog เมื่อสร้างห้องสำเร็จ
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Please enter both room name and password')),
                  );
                }
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับสร้าง roomId แบบสุ่ม
  String _generateRoomId() {
    final Random _random = Random();
    return List.generate(5, (_) => _random.nextInt(10))
        .join(); // สุ่มตัวเลข 5 ตัว
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(chatRooms[index]['name']),
                onTap: () => onSelectChatRoom(
                  chatRooms[index]['id'],
                  chatRooms[index]['name'],
                ),
                selected: selectedChatRoomId == chatRooms[index]['id'],
                selectedTileColor: Colors.blueAccent.withOpacity(0.2),
              );
            },
          ),
        ),
        // ปุ่มสำหรับสร้างห้องแชทใหม่
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Create Chat Room'),
          onTap: () {
            _createChatRoom(context); // เรียกฟังก์ชันสร้างห้องแชท
          },
        ),
      ],
    );
  }
}
