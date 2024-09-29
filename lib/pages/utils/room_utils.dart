import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomUtils {
  static void createRoomDialog(BuildContext context, User? currentUser,
      Function(String, String) onRoomCreated) {
    String? roomName;
    String? roomPassword;

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                decoration: InputDecoration(hintText: 'Password'),
                onChanged: (value) {
                  roomPassword = value.trim();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (roomName != null && roomPassword != null) {
                  String roomId = _generateRoomId();

                  await _addChatRoomToFirestore(
                      currentUser, roomId, roomName!, roomPassword!);
                  onRoomCreated(roomId, roomName!);

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Room Created Successfully'),
                        content: Text('Room ID: $roomId'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please enter room name and password')),
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

  static Future<void> _addChatRoomToFirestore(User? currentUser, String roomId,
      String roomName, String roomPassword) async {
    await FirebaseFirestore.instance.collection('chatRooms').doc(roomId).set({
      'name': roomName,
      'password': roomPassword,
      'createdAt': FieldValue.serverTimestamp(),
      'creatorId': currentUser?.uid,
    });
  }

  static String _generateRoomId() {
    const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random _rnd = Random();

    return String.fromCharCodes(Iterable.generate(
        5, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static void joinRoomDialog(BuildContext context, User? currentUser,
      Function(String, String) onRoomJoined) {
    String? roomId;
    String? password;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Chat Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: 'Room ID'),
                onChanged: (value) {
                  roomId = value.trim();
                },
              ),
              TextField(
                decoration: InputDecoration(hintText: 'Password'),
                onChanged: (value) {
                  password = value.trim();
                },
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (roomId != null && password != null) {
                  try {
                    DocumentSnapshot roomSnapshot = await FirebaseFirestore
                        .instance
                        .collection('chatRooms')
                        .doc(roomId)
                        .get();

                    if (roomSnapshot.exists &&
                        roomSnapshot['password'] == password) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser!.uid)
                          .update({
                        'joinedRooms': FieldValue.arrayUnion([roomId]),
                      });

                      onRoomJoined(roomSnapshot.id, roomSnapshot['name']);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invalid Room ID or Password')),
                      );
                    }
                  } catch (e) {
                    print('Error joining room: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('An error occurred')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Please enter Room ID and Password')),
                  );
                }
              },
              child: Text('Join'),
            ),
          ],
        );
      },
    );
  }
}
