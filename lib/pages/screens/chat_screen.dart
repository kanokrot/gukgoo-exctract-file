import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gukgoo/pages/widgets/chat_message_list.dart';
import 'package:gukgoo/pages/widgets/chat_room_list.dart';
import 'package:gukgoo/pages/screens/notification_page.dart';
import 'package:gukgoo/pages/screens/profile.dart';
import 'package:gukgoo/pages/utils/room_utils.dart';
import 'package:gukgoo/pages/services/chat_service.dart';

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> chatRooms = [];
  String selectedChatRoomId = '';
  String selectedChatRoomName = 'General Chat';
  List<Map<String, dynamic>> messages = [];
  bool _hasJoinedRoom = false;
  User? currentUser;
  String currentUserName = 'Unknown';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
    });

    if (currentUser != null) {
      _loadChatRooms();
      _loadCurrentUserName();
    }
  }

  void _loadCurrentUserName() async {
    currentUserName = await ChatService.getCurrentUserName(currentUser);
    setState(() {});
  }

  void _loadChatRooms() {
    ChatService.getChatRooms(currentUser!.uid).listen((rooms) {
      setState(() {
        chatRooms = rooms;
      });
    });
  }

  void _selectChatRoom(String roomId, String roomName) {
    setState(() {
      selectedChatRoomId = roomId;
      selectedChatRoomName = roomName;
      _hasJoinedRoom = true;
    });
    _loadMessages();
  }

  void _loadMessages() {
    ChatService.getMessages(selectedChatRoomId).listen((msg) {
      setState(() {
        messages = msg;
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _sendMessage() {
    ChatService.sendMessage(
      selectedChatRoomId,
      _messageController.text,
      currentUser?.uid,
      currentUserName,
    );
    _messageController.clear();
  }

  void _createChatRoom() {
    RoomUtils.createRoomDialog(context, currentUser, (roomId, roomName) {
      setState(() {
        selectedChatRoomId = roomId;
        selectedChatRoomName = roomName;
        _hasJoinedRoom = true;
      });
    });
  }

  void _joinChatRoom() {
    RoomUtils.joinRoomDialog(context, currentUser, (roomId, roomName) {
      _selectChatRoom(roomId, roomName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = <Widget>[
      _hasJoinedRoom
          ? ChatMessageList(
              messages: messages,
              currentUser: currentUser,
              messageController: _messageController,
              onSendMessage: _sendMessage,
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _joinChatRoom,
                    child: Text('Join a Room'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _createChatRoom,
                    child: Text('Create a Room'),
                  ),
                ],
              ),
            ),
      NotificationPage(onThemeChanged: () {}, isDarkMode: false),
      ProfileScreen(username: currentUserName),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body: _pages[_selectedIndex],
      drawer: Drawer(
        child: ChatRoomList(
          chatRooms: chatRooms,
          onSelectChatRoom: _selectChatRoom,
          selectedChatRoomId: selectedChatRoomId,
        ),
      ),
    );
  }
}
