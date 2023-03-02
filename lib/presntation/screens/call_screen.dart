import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_video/data/models/call.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/agora_manager.dart';
import '../../constants/firebase.dart';
import '../../constants/name_page.dart';
import '../../data/repository/call_repository.dart';
import '../widgets/local_remote_video_widget.dart';
import '../widgets/render_remote_video_widget.dart';

class CallScreen extends StatefulWidget {
  CallScreen({Key? key, required this.callerInfo}) : super(key: key);
  Call callerInfo;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

AudioPlayer assetsAudioPlayer = AudioPlayer();

Future<void> playContactingRing() async {
  await assetsAudioPlayer.play(AssetSource('sounds/phone.mp3'));
  assetsAudioPlayer.setReleaseMode(ReleaseMode.loop);
}

class _CallScreenState extends State<CallScreen> {
  callStream() {
    final stream = FirebaseFirestore.instance
        .collection(CallFire.callsCollections)
        .where(CallFire.stateCall, isEqualTo: 'citCaller')
        .where(CallFire.id, isEqualTo: widget.callerInfo.id)
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
    super.initState();
    playContactingRing();
    callStream();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    CallRepository.updateCall(
        stateCall: "endCalling", id: widget.callerInfo.id);
    assetsAudioPlayer.dispose();
    if (isInitAgora) {
      rtcEngine.destroy();
    }

    super.dispose();
  }

  int remoteUid = 0;
  bool isMic = false;
  bool changLocalRender = false;
  bool isInitAgora = false;
  late RtcEngine rtcEngine;
  int timerMaxSeconds = 1800;
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
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isInitAgora
            ? remoteUid == 0
                ? Stack(
                    children: [
                      Center(child: const LocalRemoteVideoWidget()),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: widget.callerInfo.callerName,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(
                                    text: 'connect',
                                    style: TextStyle(
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
                          : RenderRemoteVideoWidget( channelName: widget.callerInfo.channelName!,remoteUid: remoteUid),
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
                                  ? RenderRemoteVideoWidget(
                                channelName: widget.callerInfo.channelName!,
                                      remoteUid: remoteUid)
                                  : const LocalRemoteVideoWidget(),
                            ),
                          ),
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
                                  fillColor:
                                      isMic ? Colors.blueAccent : Colors.white,
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
                                    color: isMic
                                        ? Colors.white
                                        : Colors.blueAccent,
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
                  )
            : Container(
                color: Color(0xfff0f0f0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 40),
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: widget.callerInfo.callerName,
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          TextSpan(
                              text: "\nincoming...".toUpperCase(),
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black)),
                        ]),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 70),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          RawMaterialButton(
                              elevation: 2,
                              onPressed: () {
                                initAgora();
                              },
                              padding: const EdgeInsets.all(15),
                              shape: const CircleBorder(),
                              fillColor: Colors.greenAccent,
                              highlightColor: Colors.green,
                              child: const Icon(
                                Icons.call,
                                size: 44,
                                color: Colors.white,
                              )),
                          RawMaterialButton(
                              elevation: 2,
                              onPressed: () {
                                CallRepository.updateCall(
                                    stateCall: "citReceiver",
                                    id: widget.callerInfo.id);
                                Navigator.of(context).pop(true);
                              },
                              padding: const EdgeInsets.all(15),
                              shape: const CircleBorder(),
                              fillColor: Colors.redAccent,
                              highlightColor: Colors.red,
                              child: const Icon(
                                Icons.call_end,
                                size: 44,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> initAgora() async {
    //startTimeout();
    await [Permission.microphone, Permission.camera].request();
    rtcEngine = await RtcEngine.create(AgoraManager.appId);
    setState(() {
      isInitAgora = true;
    });

    rtcEngine.enableVideo();
    rtcEngine.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          //  print('local user $uid joined successfully');
          playContactingRing();

          setState(() {
            //timerMaxSeconds=70;
          });
        },
        userJoined: (int uid, int elapsed) async {
// player.stop();
          //print('remote user $uid joined successfully');
          assetsAudioPlayer.stop();

          setState(() => remoteUid = uid);
        },
        audioEffectFinished: (int i) {
          setState(() {});
          assetsAudioPlayer.stop();
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
       widget.callerInfo.token, widget.callerInfo.channelName!, null, 0);
  }
}
