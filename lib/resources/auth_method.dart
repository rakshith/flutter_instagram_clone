import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // signup the user

  Future<String> signupUser(
      {required String email,
      required String password,
      required String bio,
      required String username,
      required Uint8List file}) async {
    String res = "Some error occured";

    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          bio.isNotEmpty ||
          username.isNotEmpty ||
          file != null) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);
        print('UserCredential' + cred.user!.uid);

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        await _firestore.collection('users').doc(cred.user!.uid).set({
          'username': username,
          'uid': cred.user!.uid,
          'email': email,
          'bio': bio,
          'followers': [],
          'following': [],
          'photoUrl': photoUrl,
        });

        res = 'success';
        // add user to database
        //
        //
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'The email is badly formatted';
      } else if (err.code == 'weak-password') {
        res = 'Password should be at least 6 characters';
      }
    } catch (err) {
      res = err.toString();
    }

    return res;
  }
}
