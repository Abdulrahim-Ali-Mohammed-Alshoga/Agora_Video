import 'dart:async';

import 'package:agora_video/constants/arguments.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import '../../constants/firebase.dart';
import '../../constants/name_page.dart';
import '../../data/models/call.dart';
import '../../data/models/user.dart';
import '../../data/repository/token_repository.dart';
import '../../data/web_services/token_web_services.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.uid}) : super(key: key);
  String uid;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = ScrollController();
var  callSubscription;
  var uuid = Uuid();
late Call callInfo;
  TokenRepository tokenRepository=TokenRepository(TokenWebServices());
call(){

  final stream = FirebaseFirestore.instance
      .collection(CallFire.callsCollections)
      .where(CallFire.receiverId, isEqualTo: widget.uid)
      .where(CallFire.stateCall, isEqualTo: 'calling')
      .snapshots();
  stream.listen((value) {

    if(value.docs.isNotEmpty)

    {
      print(31555555);
      callInfo=Call.fromJson(value.docs[0]);
        Navigator.pushNamed(
          context,
          NamePage.callScreen,
          arguments:CallScreenArgument(callerInfo: callInfo)
        );
      }
    else{print(widget.uid);
      print("object");
    }
    });

}
  Future<void> getPermission({
    required String receiverName,
    required String callerId,
    required String callerName,
    required String receiverId,
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
        var channelName1=uuid.v4();
        tokenRepository.getToken(channelName1).then((value) => {
        Navigator.pushNamed(context, NamePage.videoCallScreen,
        arguments: VideoCallScreenArgument(
        callerId: callerId,
        token: value.tokenUnique!,
        channelName: channelName1,
        receiverId: receiverId,
        receiverName: receiverName,
        callerName: callerName))
        });

      }
    });
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();

    call();
  }
  CollectionReference messages =
      FirebaseFirestore.instance.collection(UserFire.userCollections);
      // .where(UserFire.id, isNotEqualTo: widget.uid)
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messages.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Users> userList1 = [];
          List<Users> userList = [];
          Users? user;
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            userList1.add(Users.fromJson(snapshot.data!.docs[i]));
          }
          for (var value in userList1) {
            if (value.id == widget.uid) {

              user = value;
            } else {

              userList.add(value);
            }
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.deepOrange,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('User'),
                ],
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: _controller,
                      itemCount: userList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(userList[index].name!),
                            trailing: IconButton(
                              onPressed: () {
                                getPermission(
                                    receiverName: userList[index].name!,
                                    receiverId: userList[index].id!,
                                    callerId: user!.id!,
                                callerName: user!.name!);
                              },
                              icon: const Icon(
                                Icons.video_call,
                                size: 44,
                              ),
                              color: Colors.teal,
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        } else {
          return const Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
            color: Colors.deepOrange,
          )));
        }
      },
    );
  }
}
// Scaffold(
// appBar: AppBar(
// title: const Text('Agora Video'),
// ),
// body: Column(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
//
// Padding(
// padding: const EdgeInsets.all(8.0),
// child: Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// IconButton(
// onPressed: () {
// getPermission();
//
// },
// icon: const Icon(
// Icons.video_call,
// size: 44,
// ),
// color: Colors.teal,
// ),
// IconButton(
// onPressed: () {
// // Navigator.push(
// // context,
// // MaterialPageRoute(
// // builder: (context) => AudioCallScreen()));
// },
// icon: const Icon(
// Icons.phone,
// size: 35,
// ),
// color: Colors.teal,
// ),
// ],
// ),
// ),
// ],
// ),
// )
