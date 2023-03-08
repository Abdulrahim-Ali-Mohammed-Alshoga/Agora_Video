import 'dart:async';
import 'package:agora_video/constants/arguments.dart';
import 'package:agora_video/view_model/home_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/name_page.dart';
import '../../data/models/call.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.uid}) : super(key: key);
  String uid;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeViewModel homeViewModel = HomeViewModel();
//يتم في هذه الدالة الاستماع لقاعدة البيانات اذا وقع اتصال للمستقبل يتم فتح صفحة CallScreen
  call() {
    homeViewModel.gatCallStream(widget.uid).listen((value) {
      if (value.docs.isNotEmpty) {
        homeViewModel.callInfo = Call.fromJson(value.docs[0]);
        Navigator.pushNamed(context, NamePage.callScreen,
            arguments: CallScreenArgument(callerInfo: homeViewModel.callInfo));
      }
    });
  }
//يتم في هذه الدالة الانتقال الى صفحة video call
  Future<void> getPermission({
    required String receiverName,
    required String callerId,
    required String callerName,
    required String receiverId,
  }) async {
    homeViewModel.getPermission(
        goScreenVideo: () {
          var channelName1 =homeViewModel.uuid.v4();
          homeViewModel.tokenRepository.getToken(channelName1).then((value) => {
          Navigator.pushNamed(context, NamePage.videoCallScreen,
          arguments: VideoCallScreenArgument(
          callerId: callerId,
          token: value.tokenUnique!,
          channelName: channelName1,
          receiverId: receiverId,
          receiverName: receiverName,
          callerName: callerName))
          });

        });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    call();
  }


  // .where(UserFire.id, isNotEqualTo: widget.uid)
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: homeViewModel.selectUsers(widget.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          homeViewModel.getListUser(users:snapshot.data!.docs,id: widget.uid);
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.deepOrange,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  Text(homeViewModel.title),
                ],
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: homeViewModel.controller,
                      itemCount: homeViewModel.userList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(homeViewModel.userList[index].name!),
                            trailing: IconButton(
                              onPressed: () {
                                getPermission(
                                    receiverName: homeViewModel.userList[index].name!,
                                    receiverId: homeViewModel.userList[index].id!,
                                    callerId: homeViewModel.user!.id!,
                                    callerName: homeViewModel.user!.name!);
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
