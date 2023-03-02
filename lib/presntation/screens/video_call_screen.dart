import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_video/data/repository/call_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/agora_manager.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

import '../../constants/arguments.dart';
import '../../constants/firebase.dart';
import '../widgets/local_remote_video_widget.dart';
import '../widgets/render_remote_video_widget.dart';

class VideoCallScreen extends StatefulWidget {
  VideoCallScreen({Key? key, required this.videoCSA}) : super(key: key);
  VideoCallScreenArgument videoCSA;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  int remoteUid = 0;
  bool changLocalRender = false;
  bool isMic = false;
  bool playEffect = true;
  String callingOrRinging = "Calling...";
  late RtcEngine rtcEngine;
  final calls = FirebaseFirestore.instance.collection('calls').doc();

  callStream() {
    final stream = FirebaseFirestore.instance
        .collection(CallFire.callsCollections)
        .where(CallFire.stateCall, isEqualTo: 'citReceiver')
        .where(CallFire.id, isEqualTo: calls.id)
        .snapshots();
    stream.listen((value) {
      if (value.docs.isNotEmpty) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    RtcRemoteView.SurfaceView;
    super.initState();
    initAgora();
    callStream();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    rtcEngine.destroy();
    assetsAudioPlayer.dispose();
    CallRepository.updateCall(stateCall: "endCalling", id: calls.id);
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
                    children: [
                      const LocalRemoteVideoWidget(),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: widget.videoCSA.receiverName,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text: '\n$callingOrRinging',
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black)),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      changLocalRender
                          ? const LocalRemoteVideoWidget()
                          : RenderRemoteVideoWidget(channelName: widget.videoCSA.channelName,remoteUid: remoteUid),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Text(timerText,
                              style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            changLocalRender = !changLocalRender;
                          });
                        },
                        child: SafeArea(
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              height: 160,
                              width: 110,
                              margin: const EdgeInsets.only(top: 15, left: 25),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: changLocalRender
                                  ? RenderRemoteVideoWidget(channelName: widget.videoCSA.channelName,
                                      remoteUid: remoteUid)
                                  : const LocalRemoteVideoWidget(),
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
                        CallRepository.updateCall(id: calls.id, stateCall: "citCaller");
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

  AudioPlayer assetsAudioPlayer = AudioPlayer();

  addCallFire() {
    calls.set({
      CallFire.callerName: widget.videoCSA.callerName, // John Doe
      CallFire.id: calls.id, // John Doe
      CallFire.receiverName: widget.videoCSA.receiverName, // John Doe
      CallFire.callerId: widget.videoCSA.callerId, // John Doe
      CallFire.receiverId: widget.videoCSA.receiverId, // John Doe
      CallFire.stateCall: "calling",
      CallFire.token:widget.videoCSA.token,
      CallFire.channelName: widget.videoCSA.channelName,
    });
  }

  Future<void> initAgora() async {
    startTimeout();
    // await [Permission.microphone, Permission.camera].request();
    rtcEngine = await RtcEngine.create(AgoraManager.appId);

    rtcEngine
        .enableVideo();

    rtcEngine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          addCallFire();
          //  print('local user $uid joined successfully');
          playContactingRing();
          callingOrRinging = 'Ringing';
          setState(() {
            timerMaxSeconds = 70;
          });
        },
        userJoined: (int uid, int elapsed) async {
// player.stop();
          //print('remote user $uid joined successfully');
          assetsAudioPlayer.stop();
          timerMaxSeconds = 1800;
          setState(() => remoteUid = uid);
        },

        userOffline: (int uid, UserOfflineReason reason) async {
          // print('remote user $uid left call');
          await assetsAudioPlayer.stop();
          setState(() => remoteUid = 0);

          Navigator.of(context).pop();
        },
      ),
    );

    //await rtcEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    // await rtcEngine.enableVideo();
    //rtcEngine.enableWebSdkInteroperability(true);
    // rtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    // rtcEngine.setParameters("{\"rtc.log_filter\": 65535}");
    await rtcEngine.startPreview();
    await rtcEngine.joinChannel(
        widget.videoCSA.token, widget.videoCSA.channelName, null, 0);
  }

  int timerMaxSeconds = 40;
  int currentSeconds = 0;

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  startTimeout() {
    var duration = const Duration(seconds: 1);
    Timer.periodic(duration, (timer) {
      setState(() {
        currentSeconds = timer.tick;
        if (timer.tick >= timerMaxSeconds) {
          timer.cancel();
          rtcEngine.leaveChannel();
          Navigator.of(context).pop(true);
        }
      });
    });
  }

  Future<void> playContactingRing() async {
    await assetsAudioPlayer
        .play(AssetSource('sounds/phone_calling_Sound_Effect.mp3'));
    assetsAudioPlayer.setReleaseMode(ReleaseMode.loop);
    // ByteData bytes = await rootBundle.load(audioAsset);
    // Uint8List  soundBytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    // if(result == 1){ //play success
    //   debugPrint("Sound playing successful.");
    // }else{
    //   debugPrint("Error while playing sound.");
    // }
    // if(isCaller){
    //   startCountdownCallTimer();
    // }
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
