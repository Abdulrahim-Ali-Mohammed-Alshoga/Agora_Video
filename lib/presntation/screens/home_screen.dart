import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/arguments.dart';
import '../../constants/name_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  getPermission() async{
    bool checkPermission=true;
    await [Permission.microphone, Permission.camera].request().then((value) {
      for (var value1 in value.values.toList()) {
        if (value1.toString() == 'PermissionStatus.denied') {
         checkPermission=false;
          break;
        }
      }
      // setState(() {
      //
      // });
      if(checkPermission){
        Navigator.pushNamed(
            context,
            NamePage.videoCallScreen);
      }
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agora Video'),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

    Padding(
    padding: const EdgeInsets.all(8.0),
    child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
    IconButton(
    onPressed: () {
      getPermission();

    },
    icon: const Icon(
    Icons.video_call,
    size: 44,
    ),
    color: Colors.teal,
    ),
    IconButton(
    onPressed: () {
    // Navigator.push(
    // context,
    // MaterialPageRoute(
    // builder: (context) => AudioCallScreen()));
    },
    icon: const Icon(
    Icons.phone,
    size: 35,
    ),
    color: Colors.teal,
    ),
    ],
    ),
    ),
    ],
    ),
    );

  }
}
