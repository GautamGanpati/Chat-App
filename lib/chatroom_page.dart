import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatelessWidget {
  ChatRoom({super.key, required this.chatRoomId, required this.userMap});

  final Map<String, dynamic> userMap;
  final String chatRoomId;

  final TextEditingController _message = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> messages = {
        "sendby": FirebaseAuth.instance.currentUser!.displayName.toString(),
        "message": _message.text,
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();
      await firestore
          .collection('chatroom')
          .doc(chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          elevation: 5,
          title: StreamBuilder<DocumentSnapshot>(
              stream:
                  firestore.collection('users').doc(userMap["uid"]).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data != null) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userMap['name']),
                        Text(
                          snapshot.data!["status"],
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container();
                }
              }),
          centerTitle: false,
          leading: const Padding(
            padding: EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundImage: AssetImage('assets/images/user.png'),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                      stream: firestore
                          .collection('chatroom')
                          .doc(chatRoomId)
                          .collection('chats')
                          .orderBy("time", descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic> map =
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>;
                                return messages(map);
                              });
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })),
              Container(
                constraints: const BoxConstraints(minHeight: 50, maxHeight: 100),
                child: Row(
                  children: [
                    Container(
                      child: Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              border: Border.all(
                                color: Colors.deepPurple,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: TextField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: _message,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Say hi',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      color: Colors.deepPurple,
                      onPressed: onSendMessage,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget messages(Map<String, dynamic> map) {
    return Container(
      alignment: map['sendby'] ==
              FirebaseAuth.instance.currentUser!.displayName.toString()
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.deepPurple,
        ),
        child: Text(
          map['message'],
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
