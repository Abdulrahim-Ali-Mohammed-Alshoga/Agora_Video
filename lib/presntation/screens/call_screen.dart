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
//تعمل الدالة على تحديد مكان الملف الصوتي وتشغيلة وعند الانتهاء يتم تشغيلة مرة اخرى
Future<void> playContactingRing() async {
  await assetsAudioPlayer.play(AssetSource('sounds/phone.mp3'));
  assetsAudioPlayer.setReleaseMode(ReleaseMode.loop);
}

class _CallScreenState extends State<CallScreen> {
  //يتم في هذه الدالة الاستماع للمتصل اذا رفض المكالة قبل ان يرتبط
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

//تشغيل رنة الاتصال  وبداء الاستماع لقاعدة البيانات
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    playContactingRing();
    callStream();
  }

//يتم قطع الرنة وقمنا بعمل متغير باسم isInitAgora من اجل يتاكد اذا تم تشغيل rtcEngine يعمل لها اغلاق ويقطع الاتصال من الطرفين المتصل و المستقبل
  @override
  void dispose() {
    // TODO: implement dispose
    // CallRepository.updateCall(
    //     stateCall: "endCalling", id: widget.callerInfo.id);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //المتغير isInitAgora من اعماله ايضا اذا تم وصول المكالة بيكون false فيتم فتح وجهة الرنة فاذا قبل المستقبل الاتصال تتغير الوجة الى واجهة الاتصال واذا رفض ترجع للصفحة السابقة
      body: isInitAgora
      //المتغير remoteUid قمنا بعملة لكي اذا قبل المستقبل الاتصال تتغير الوجة الى واجهة الاتصال اذا كان المتغير لا يسوي 0 واذا رجعت 0 تكون وجهة حق الرنة
          ? remoteUid == 0
                ? Stack(
                    children: [
                      //هنا يتم عرض الكاميرة الامامية للمستخدم
                      const Center(child: LocalRemoteVideoWidget()),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(children: [
                                TextSpan(
                                  // اسم المستقبل
                                    text: widget.callerInfo.callerName,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                const TextSpan(
                                    text: '\nconnect',
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
                      //هذا المتغير من اجل التغيير بين الشاشتيين الكبيرة والصغيرة
                      changLocalRender
                      //هنا يتم عرض الكاميرة  للمتصل في الشاشة الكبيرة اذا المتغير changLocalRender يساوي true
                          ? const LocalRemoteVideoWidget()
                      //  هنا يتم عرض الكاميرة للمستقبل في الشاشة الكبيرة  اذا المتغير changLocalRender يساوي false
                          : RenderRemoteVideoWidget(
                              channelName: widget.callerInfo.channelName!,
                              remoteUid: remoteUid),
                      GestureDetector(
                        onTap: () {
                          //هنا يتم امر التبديل بين الشاشتين الكبيرة و الصغيرة
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
                              //هنا يتم عرض الكاميرة للمتصل في الشاشة الصغيرة  اذا المتغير changLocalRender يساوي false
                                  ? RenderRemoteVideoWidget(
                                      channelName:
                                          widget.callerInfo.channelName!,
                                      remoteUid: remoteUid)
                              //هنا يتم عرض الكاميرة للمستقبل في الشاشة الصغيرة اذا المتغير changLocalRender يساوي true
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
                                      //هنا يتم امر التبديل بين كتم الصوت وفتحة
                                      isMic = !isMic;
                                    });
                                    rtcEngine.muteAllRemoteAudioStreams(isMic);
                                  },
                                  child: Icon(
                                    //هنا يتم تبديل بين الايقونة بين ايقونة كتم وفتح الصوت
                                    isMic ? Icons.mic_off : Icons.mic,
                                    //هنا يتم تبديل الالوان الايقونة
                                    color: isMic
                                        ? Colors.white
                                        : Colors.blueAccent,
                                    size: 30,
                                  )),
                              RawMaterialButton(
                                  elevation: 2,
                                  onPressed: () {
                                    //قطع الاتصال اي من الطرفين المتصل و المستقبل والرجوع الى الصفحة السابقة
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
                                    //هنا يتم امر التبديل بين الكاميرا الامامية والخلفية
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
            :
      //يتم عرض الواجهة الذي تعلم المستقبل بالاتصال بحيث يقبل او يرفض
      Container(
                color: const Color(0xfff0f0f0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 70, left: 40),
                      child: RichText(
                        text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            //اسم المتصل
                            text: widget.callerInfo.callerName,
                            style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          TextSpan(
                              text: "\nincoming...".toUpperCase(),
                              style:
                                  const TextStyle(fontSize: 20, color: Colors.black)),
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
                                // قبول الاتصال ويتم بداء تشغيل دالة initAgora المتعلق بجميع عمليات الاتصال
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
                                //يتم رفض المكالمة والرجوع الى الصفحة السابقة وايضا الرنة وتحديث قاعدة البيانات بان الاتصال انتهاء من قبل المستقبل وقطع الاتصال اذا كان المتصل في حالة الرنة بحيث يتم تغيير stateCall المتعلقة بهذا الاتصال الى citReceiver
                                // CallRepository.updateCall(
                                //     stateCall: "citReceiver",
                                //     id: widget.callerInfo.id);
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
// هذه الدالة تتعامل مع جميع عمليات الاتصال
  Future<void> initAgora() async {
    //startTimeout();
    //يتم هنا التاكد من ان المستخدم قد اذن للتطبيق الوصول الى الكامير و الميكرفون فاذا لما ياذن يقوم بطلب الاذن منه
    //ي اضافة خارجية اسمها permission_handler
    await [Permission.microphone, Permission.camera].request();
    rtcEngine = await RtcEngine.create(AgoraManager.appId);

    setState(() {
      //يتم تغيير الواجهه بعدقبول الاتصال الى وجهه المتعلقة بالربط
      isInitAgora = true;
    });
    //هذا الامر يسمح بتشغيل خاصية الفيديو
    rtcEngine.enableVideo();
    rtcEngine.setEventHandler(
      RtcEngineEventHandler(
        //تعمل الدالة عند ما يتم محاولة الارتباط اي قبل ما تتم عملية الاتصال وبداء المحادثة
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          //  print('local user $uid joined successfully');
    setState(() {
            //timerMaxSeconds=70;
          });
        },
        //تعمل الدالة عندما يتم بداء الاتصال بين الطرفين
        userJoined: (int uid, int elapsed) async {
// player.stop();
          //print('remote user $uid joined successfully');
          // يتم قطع الرنة
          assetsAudioPlayer.stop();
// تحويل المتغير remoteUid الى رقم غير 0 من اجل تتغير الوججه الى واجهه المحادثة بين الطرفين
          setState(() => remoteUid = uid);
        },
        //تعمل الدالة عندما يقوم المتصل اي الطرف الاخر بقطع الاتصال
        userOffline: (int uid, UserOfflineReason reason) async {
          // print('remote user $uid left call');
          //يتم قطع الاتصال بين الطرفين والرجوع الى الصفحة السابقة وايضا تحويل المتغير remoteUid الى 0
          setState(() => remoteUid = 0);

          Navigator.of(context).pop();
        },
      ),
    );
    //تشغيل الكاميرا اول ما ندخل الصفحة يعني قبل حتى ما تشتغل دالة joinChannelSuccess
    await rtcEngine.startPreview();
    //آخر شيء في وظيفة rtcEngine ، نحتاج إلى ضم المستقبل إلى القناة. من خلال الحصول على الرمز المميز التوكن من قاعدة البيانات .وايضا على اسم القناة وبهذا يمكننا ببساطة الانضمام إلى القناة في مكان آخر
    await rtcEngine.joinChannel(
        widget.callerInfo.token, widget.callerInfo.channelName!, null, 0);
  }
}
