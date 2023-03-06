import 'package:agora_video/constants/arguments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/firebase.dart';
import '../models/user.dart';

class SingInRepository {
  CollectionReference userFirebase =
      FirebaseFirestore.instance.collection('users');
  late String id;
  late Users user;

  Future<void> setSingIn(
      {required String email,
      required String password,
      required String name}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) {
        id = value.user!.uid;
        user == Users(id: id, password: password, name: name, email: email);
        userFirebase.add({
          user.toMap() // Stokes and Sons
        });
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }
}
