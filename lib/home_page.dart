import 'package:chat_app/chatroom_page.dart';
import 'package:chat_app/methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  bool isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? userMap;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //online
      setStatus("Online");
    } else {
      //offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    if (_searchController.text.isNotEmpty) {
      await firestore
          .collection('users')
          .where('email', isEqualTo: _searchController.text)
          .get()
          .then((value) {
        setState(() {
          userMap = value.docs[0].data();
          isLoading = false;
          _searchController.clear();
        });
        print(userMap);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        title: const Text('Chats'),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () {
                logOut(context);
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25.0, vertical: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      border: Border.all(
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration.collapsed(
                                hintText: "Search"),
                          ),
                        )),
                        IconButton(
                          color: Colors.deepPurple[600],
                          onPressed: onSearch,
                          icon: const Icon(Icons.search_rounded),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: userMap != null
                      ? ListTile(
                          tileColor: Colors.deepPurple[200],
                          onTap: () {
                            String roomId = chatRoomId(
                                FirebaseAuth.instance.currentUser!.displayName
                                    .toString(),
                                userMap!['name']);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatRoom(
                                  chatRoomId: roomId,
                                  userMap: userMap!,
                                ),
                              ),
                            );
                          },
                          leading: const CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                AssetImage('assets/images/user.png'),
                          ),
                          title: Text(
                            userMap!['name'],
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(userMap!['email']),
                        )
                      : Container(),
                ),
              ],
            ),
    );
  }
}
