import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/firebase.dart';
import '../../constants/name_page.dart';
import '../../data/models/user.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key, required this.uid}) : super(key: key);
  String uid;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = ScrollController();

  getPermission() async {
    bool checkPermission = true;
    await [Permission.microphone, Permission.camera].request().then((value) {
      for (var value1 in value.values.toList()) {
        if (value1.toString() == 'PermissionStatus.denied') {
          checkPermission = false;
          break;
        }
      }
      // setState(() {
      //
      // });
      if (checkPermission) {
        Navigator.pushNamed(context, NamePage.videoCallScreen);
      }
    });
  }

  CollectionReference messages =
      FirebaseFirestore.instance.collection(UserFire.userCollections);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messages.where(UserFire.id, isNotEqualTo: widget.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<Users> userList = [];
          for (int i = 0; i < snapshot.data!.docs.length; i++) {
            userList.add(Users.fromJson(snapshot.data!.docs[i]));
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
                                getPermission();
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
