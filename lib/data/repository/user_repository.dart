import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firebase.dart';

class UserRepository{
  // Query<Map<String, dynamic>> select({required String id}) {
  //   return FirebaseFirestore.instance.collection(UserFire.userCollections).where(UserFire.id,isNotEqualTo: id);
  // }
  CollectionReference selectUser(){
  return FirebaseFirestore.instance.collection(UserFire.userCollections);
  }


}