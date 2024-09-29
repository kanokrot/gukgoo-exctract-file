import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  final Function onThemeChanged;
  final bool isDarkMode;

  NotificationPage({required this.onThemeChanged, required this.isDarkMode});

  final List<Map<String, String>> notifications = [
    {
      "title": "New message from Alice",
      "subtitle": "You: How are you?",
      "time": "1 min ago"
    },
    {
      "title": "New group message in 'Flutter Devs'",
      "subtitle": "John: Have you seen this?",
      "time": "5 min ago"
    },
    {
      "title": "New message from Bob",
      "subtitle": "Bob: Let's catch up later.",
      "time": "10 min ago"
    },
    {
      "title": "Reminder: Meeting at 4 PM",
      "subtitle": "",
      "time": "30 min ago"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              onThemeChanged();
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(notifications[index]['title']!),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              notifications.removeAt(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Notification dismissed"),
                ),
              );
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: ListTile(
              leading: Icon(Icons.notifications,
                  color: isDarkMode ? Colors.white : Colors.teal),
              title: Text(notifications[index]['title']!),
              subtitle: notifications[index]['subtitle']!.isNotEmpty
                  ? Text(notifications[index]['subtitle']!)
                  : null,
              trailing: Text(
                notifications[index]['time']!,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
