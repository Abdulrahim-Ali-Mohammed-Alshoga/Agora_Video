import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import '../constants/arguments.dart';
import '../constants/firebase.dart';
import '../data/models/call.dart';
import '../data/models/user.dart';
import '../data/repository/call_repository.dart';
import '../data/repository/token_repository.dart';
import '../data/repository/user_repository.dart';
import '../data/web_services/token_web_services.dart';

class HomeViewModel {
  final controller = ScrollController();
  Uuid uuid = const Uuid();
  late Call callInfo;
  String title = "User";
 late List<Users> userList;
  late List<Users> userList1;
  Users? user;
  UserRepository userRepository =UserRepository();
  CallRepository callRepository = CallRepository();
  TokenRepository tokenRepository = TokenRepository(TokenWebServices());

  Stream<QuerySnapshot<Map<String, dynamic>>> gatCallStream(String id) {
    return callRepository.gatCallStream(id: id, cut: 'calling');
  }
selectUsers(String id){
  return  userRepository.selectUser();
}
  Future<void> getPermission({
    required Function goScreenVideo,
  }) async {
    bool checkPermission = true;
    await [Permission.microphone, Permission.camera].request().then((value) {
      for (var value1 in value.values.toList()) {
        if (value1.toString() == 'PermissionStatus.denied') {
          checkPermission = false;
          break;
        }
      }
      if (checkPermission) {
        goScreenVideo();
      }
    });
  }
 getListUser({var users,required String id}){
   userList = [];
   userList1 = [];
   for (int i = 0; i < users.length; i++) {
     userList1.add(Users.fromJson(users[i]));
   }
   for (var value in userList1) {
     if (value.id == id) {
       user = value;
     } else {
       userList.add(value);
     }
   }
  }
}
