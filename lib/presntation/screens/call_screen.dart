import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/agora_manager.dart';
import '../../constants/name_page.dart';
import '../widgets/local_remote_video_widget.dart';
import '../widgets/render_remote_video_widget.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({Key? key}) : super(key: key);

  @override
  State<CallScreen> createState() => _CallScreenState();
}

AudioPlayer assetsAudioPlayer = AudioPlayer();

Future<void> playContactingRing() async {
  await assetsAudioPlayer.play(AssetSource('sounds/phone.mp3'));
  assetsAudioPlayer.setReleaseMode(ReleaseMode.loop);
}

class _CallScreenState extends State<CallScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playContactingRing();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    assetsAudioPlayer.dispose();
    rtcEngine.destroy();
    super.dispose();
  }

  int remoteUid = 0;
  bool changLocalRender = false;
  late RtcEngine rtcEngine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: remoteUid == 0
            ? Container(
                color: Color(0xfff0f0f0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 40),
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          const TextSpan(
                            text: "data",
                            style: TextStyle(
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
                              ? RenderRemoteVideoWidget(remoteUid: remoteUid)
                              : const LocalRemoteVideoWidget(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> initAgora() async {
    //startTimeout();
    await [Permission.microphone, Permission.camera].request();
    rtcEngine = await RtcEngine.create(AgoraManager.appId);

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
        AgoraManager.token, AgoraManager.channelName, null, 0);
  }
}
