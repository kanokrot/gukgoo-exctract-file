import 'package:flutter/material.dart';

class FriendsListPage extends StatefulWidget {
  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  List<Map<String, String>> friends = [
    {'id': '1', 'name': 'Alice'},
    {'id': '2', 'name': 'Bob'},
    {'id': '3', 'name': 'Charlie'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends List'),
      ),
      body: ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return ListTile(
            title: Text(friend['name']!),
            subtitle: Text('ID: ${friend['id']}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _removeFriend(context, friend['id']!);
              },
            ),
            onTap: () {
              // เปิดหน้าโปรไฟล์เพื่อนหรือรายละเอียดเพื่อน
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendDetailPage(
                    name: friend['name']!,
                    id: friend['id']!,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addFriendDialog(context);
        },
        child: Icon(Icons.person_add),
        tooltip: 'Add Friend',
      ),
    );
  }

  void _removeFriend(BuildContext context, String id) {
    setState(() {
      friends.removeWhere((friend) => friend['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Friend with ID $id removed')),
    );
  }

  void _addFriendDialog(BuildContext context) {
    String? newFriendName;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Friend'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter friend\'s name'),
            onChanged: (value) {
              newFriendName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newFriendName != null && newFriendName!.isNotEmpty) {
                  _addFriend(newFriendName!);
                }
                Navigator.pop(context); // ปิด dialog
              },
              child: Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ปิด dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _addFriend(String name) {
    setState(() {
      friends.add({'id': (friends.length + 1).toString(), 'name': name});
    });
  }
}

class FriendDetailPage extends StatelessWidget {
  final String name;
  final String id;

  const FriendDetailPage({Key? key, required this.name, required this.id})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Center(
        child: Text('Details of $name (ID: $id)'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: FriendsListPage(),
  ));
}
