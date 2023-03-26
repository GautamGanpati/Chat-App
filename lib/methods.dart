import 'package:chat_app/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<User?> createAccount(String name, String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    User? user = (await auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print('Account Created Succesfully');

      user.updateDisplayName(name);

      await firestore.collection('users').doc(auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Unavaliable",
        "uid": auth.currentUser!.uid
      });

      return user;
    } else {
      print('Account Creation Failed');
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> logIn(String email, String password) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    User? user = (await auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print('Login Sucessfull');
      return user;
    } else {
      print('Login Failed');
      return user;
    }
  } catch (e) {
    print(e);
    return null;
  }
}

Future logOut(BuildContext context) async {
  FirebaseAuth auth = FirebaseAuth.instance;

  try {
    await auth.signOut().then((value) => {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        });
  } catch (e) {
    print('error');
  }
}
