import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/agora_manager.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

import '../widgets/local_remote_video_widget.dart';
import '../widgets/render_remote_video_widget.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int remoteUid = 0;
  bool changLocalRender = false;
  bool isMic = false;
  late RtcEngine rtcEngine;

  @override
  void initState() {
    // TODO: implement initState
    RtcRemoteView.SurfaceView;
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    rtcEngine.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: remoteUid == 0
                ? Stack(
                    children: const [
                      LocalRemoteVideoWidget(),
                      Positioned(
                        top: 50,
                        right: 0,
                        left: 0,
                        child: SafeArea(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Text("Calling...",
                                style: TextStyle(
                                    fontSize: 25, color: Colors.black)),
                          ),
                        ),
                      ),

                    ],
                  )
                : Stack(
                    children: [
                      changLocalRender
                          ? const LocalRemoteVideoWidget()
                          : RenderRemoteVideoWidget(remoteUid: remoteUid),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            changLocalRender = !changLocalRender;
                          });
                        },
                        child: Positioned(
                          right: 0,
                          top: 15,
                          bottom: 0,
                          left: 25,
                          child: SafeArea(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                height: 160,
                                width: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: changLocalRender
                                    ? RenderRemoteVideoWidget(
                                        remoteUid: remoteUid)
                                    : const LocalRemoteVideoWidget(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RawMaterialButton(
                      padding: const EdgeInsets.all(12),
                      fillColor: isMic ? Colors.blueAccent : Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      onPressed: () {
                        setState(() {
                          isMic = !isMic;
                        });
                        rtcEngine.muteAllRemoteAudioStreams(isMic);
                      },
                      child: Icon(
                        isMic ? Icons.mic_off : Icons.mic,
                        color: isMic ? Colors.white : Colors.blueAccent,
                        size: 30,
                      )),
                  RawMaterialButton(
                      elevation: 2,
                      onPressed: () {
                        rtcEngine.leaveChannel();
                        Navigator.of(context).pop(true);
                      },
                      padding: const EdgeInsets.all(15),
                      shape: const CircleBorder(),
                      fillColor: Colors.redAccent,
                      child: const Icon(
                        Icons.call_end,
                        size: 44,
                        color: Colors.white,
                      )),
                  RawMaterialButton(
                      elevation: 2,
                      fillColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      onPressed: () {
                        rtcEngine.switchCamera();
                      },
                      child: const Icon(
                        Icons.switch_camera,
                        size: 30,
                        color: Colors.blueAccent,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> initAgora() async {
    rtcEngine =
        await RtcEngine.createWithContext(RtcEngineContext(AgoraManager.appId));
    rtcEngine.enableVideo();
    rtcEngine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
        //  print('local user $uid joined successfully');
        },
        userJoined: (int uid, int elapsed) {
// player.stop();
          //print('remote user $uid joined successfully');
          setState(() => remoteUid = uid);
        },
        userOffline: (int uid, UserOfflineReason reason) {
         // print('remote user $uid left call');
          setState(() => remoteUid = 0);
          Navigator.of(context).pop();
        },
      ),
    );

    // await rtcEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await rtcEngine.enableVideo();
    await rtcEngine.startPreview();
    await rtcEngine.joinChannel(
        AgoraManager.token, AgoraManager.channelName, null, 0);
  }
// Widget remoteVideo() {
//   if (remoteUid != 0) {
//     return AgoraVideoView(
//       controller: VideoViewController.remote(
//         rtcEngine: rtcEngine,
//         canvas: VideoCanvas(uid: remoteUid),
//         connection: const RtcConnection(channelId: AgoraManager.channelName),
//       ),
//     );
//   } else {
//     return const Center(
//       child:  Text(
//         'Please wait for remote user to join',
//         style: TextStyle(color: Colors.black),
//         textAlign: TextAlign.center,
//       ),
//     );
//   }
// }
}
