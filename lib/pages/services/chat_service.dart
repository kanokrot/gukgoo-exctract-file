import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  static Future<String> getCurrentUserName(User? user) async {
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    } else {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      return userSnapshot.exists
          ? userSnapshot['displayName'] ?? 'Unknown'
          : 'Unknown';
    }
  }

  static Stream<List<Map<String, dynamic>>> getChatRooms(String userId) {
    return FirebaseFirestore.instance
        .collection('chatRooms')
        .where('creatorId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                'name': doc['name'],
                'password': doc['password'],
                'creatorId': doc['creatorId'],
              };
            }).toList());
  }

  static Stream<List<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'content': doc['content'],
                'senderId': doc['senderId'],
                'senderName': doc['senderName'],
              };
            }).toList());
  }

  static Future<void> sendMessage(String chatRoomId, String content,
      String? senderId, String senderName) async {
    var messageCollection = FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages');

    await messageCollection.add({
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
