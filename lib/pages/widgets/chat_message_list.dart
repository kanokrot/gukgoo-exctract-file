import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessageList extends StatelessWidget {
  final List<Map<String, dynamic>> messages;
  final User? currentUser;
  final TextEditingController messageController;
  final VoidCallback onSendMessage;

  const ChatMessageList({
    required this.messages,
    required this.currentUser,
    required this.messageController,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              bool isSender = messages[index]['senderId'] == currentUser?.uid;
              String senderName = messages[index]['senderName'];

              return Column(
                crossAxisAlignment: isSender
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      senderName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Align(
                    alignment:
                        isSender ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSender ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                          bottomLeft: isSender
                              ? Radius.circular(15)
                              : Radius.circular(0),
                          bottomRight: isSender
                              ? Radius.circular(0)
                              : Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        messages[index]['content'],
                        style: TextStyle(
                          color: isSender ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Enter a message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: onSendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
