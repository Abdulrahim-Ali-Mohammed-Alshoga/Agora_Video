import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_video/data/models/call.dart';
import 'package:flutter/material.dart';
import '../../constants/agora_manager.dart';
import '../../view_model/call_view_model.dart';
import '../widgets/local_remote_video_widget.dart';
import '../widgets/render_remote_video_widget.dart';

class CallScreen extends StatefulWidget {
  CallScreen({Key? key, required this.callerInfo}) : super(key: key);
  Call callerInfo;

  @override
  State<CallScreen> createState() => _CallScreenState();
}



class _CallScreenState extends State<CallScreen> {
  CallViewModel callViewModel = CallViewModel();

  //يتم في هذه الدالة الاستماع للمتصل اذا رفض المكالة قبل ان يرتبط
  callStream() {
   callViewModel.gatCallStream(widget.callerInfo.id).listen((value) {
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
    callViewModel.playContactingRing();
    callStream();
  }

//يتم قطع الرنة وقمنا بعمل متغير باسم isInitAgora من اجل يتاكد اذا تم تشغيل rtcEngine يعمل لها اغلاق ويقطع الاتصال من الطرفين المتصل و المستقبل
  @override
  void dispose() {
    // TODO: implement dispose
    callViewModel.updateCall(stateCall: "endCalling", id: widget.callerInfo.id);
    callViewModel.assetsAudioPlayer.dispose();
    if (callViewModel.isInitAgora) {
      callViewModel.rtcEngine.destroy();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        //المتغير isInitAgora من اعماله ايضا اذا تم وصول المكالة بيكون false فيتم فتح وجهة الرنة فاذا قبل المستقبل الاتصال تتغير الوجة الى واجهة الاتصال واذا رفض ترجع للصفحة السابقة
        body: callViewModel.isInitAgora
            //المتغير remoteUid قمنا بعملة لكي اذا قبل المستقبل الاتصال تتغير الوجة الى واجهة الاتصال اذا كان المتغير لا يسوي 0 واذا رجعت 0 تكون وجهة حق الرنة
            ? callViewModel.remoteUid == 0
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
                      callViewModel.changLocalRender
                          //هنا يتم عرض الكاميرة  للمتصل في الشاشة الكبيرة اذا المتغير changLocalRender يساوي true
                          ? const LocalRemoteVideoWidget()
                          //  هنا يتم عرض الكاميرة للمستقبل في الشاشة الكبيرة  اذا المتغير changLocalRender يساوي false
                          : RenderRemoteVideoWidget(
                              channelName: widget.callerInfo.channelName!,
                              remoteUid: callViewModel.remoteUid),
                      GestureDetector(
                        onTap: () {
                          //هنا يتم امر التبديل بين الشاشتين الكبيرة و الصغيرة
                          setState(() {
                            callViewModel.changLocalRender =
                                !callViewModel.changLocalRender;
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
                              child: callViewModel.changLocalRender
                                  //هنا يتم عرض الكاميرة للمتصل في الشاشة الصغيرة  اذا المتغير changLocalRender يساوي false
                                  ? RenderRemoteVideoWidget(
                                      channelName:
                                          widget.callerInfo.channelName!,
                                      remoteUid: callViewModel.remoteUid)
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
                                  fillColor: callViewModel.isMic
                                      ? Colors.blueAccent
                                      : Colors.white,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  onPressed: () {
                                    setState(() {
                                      //هنا يتم امر التبديل بين كتم الصوت وفتحة
                                      callViewModel.isMic =
                                          !callViewModel.isMic;
                                    });
                                    callViewModel.rtcEngine
                                        .muteAllRemoteAudioStreams(
                                            callViewModel.isMic);
                                  },
                                  child: Icon(
                                    //هنا يتم تبديل بين الايقونة بين ايقونة كتم وفتح الصوت
                                    callViewModel.isMic
                                        ? Icons.mic_off
                                        : Icons.mic,
                                    //هنا يتم تبديل الالوان الايقونة
                                    color: callViewModel.isMic
                                        ? Colors.white
                                        : Colors.blueAccent,
                                    size: 30,
                                  )),
                              RawMaterialButton(
                                  elevation: 2,
                                  onPressed: () {
                                    //قطع الاتصال اي من الطرفين المتصل و المستقبل والرجوع الى الصفحة السابقة
                                    callViewModel.rtcEngine.leaveChannel();
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
                                    callViewModel.rtcEngine.switchCamera();
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
                              style: const TextStyle(
                                  fontSize: 20, color: Colors.black)),
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
                                callViewModel.updateCall(
                                    stateCall: "cutReceiver",
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

// هذه الدالة تتعامل مع جميع عمليات الاتصال
  Future<void> initAgora() async {
    //startTimeout();
    //يتم هنا التاكد من ان المستخدم قد اذن للتطبيق الوصول الى الكامير و الميكرفون فاذا لما ياذن يقوم بطلب الاذن منه
    //ي اضافة خارجية اسمها permission_handler
    callViewModel.permission();
    callViewModel.rtcEngine = await RtcEngine.create(AgoraManager.appId);

    setState(() {
      //يتم تغيير الواجهه بعدقبول الاتصال الى وجهه المتعلقة بالربط
      callViewModel.isInitAgora = true;
    });
    //هذا الامر يسمح بتشغيل خاصية الفيديو
    callViewModel.rtcEngine.enableVideo();
    callViewModel.rtcEngine.setEventHandler(
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
          callViewModel.assetsAudioPlayer.stop();
// تحويل المتغير remoteUid الى رقم غير 0 من اجل تتغير الوججه الى واجهه المحادثة بين الطرفين
          setState(() => callViewModel.remoteUid = uid);
        },
        // audioEffectFinished: (int i) {
        //   setState(() {});
        //   assetsAudioPlayer.stop();
        // },
        //تعمل الدالة عندما يقوم المتصل اي الطرف الاخر بقطع الاتصال
        userOffline: (int uid, UserOfflineReason reason) async {
          // print('remote user $uid left call');
          //يتم قطع الاتصال بين الطرفين والرجوع الى الصفحة السابقة وايضا تحويل المتغير remoteUid الى 0
          setState(() => callViewModel.remoteUid = 0);

          Navigator.of(context).pop();
        },
      ),
    );

    //await rtcEngine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    // await rtcEngine.enableVideo();
    //rtcEngine.enableWebSdkInteroperability(true);
    // rtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    // rtcEngine.setParameters("{\"rtc.log_filter\": 65535}");
    //تشغيل الكاميرا اول ما ندخل الصفحة يعني قبل حتى ما تشتغل دالة joinChannelSuccess
    await callViewModel.rtcEngine.startPreview();
    //آخر شيء في وظيفة rtcEngine ، نحتاج إلى ضم المستقبل إلى القناة. من خلال الحصول على الرمز المميز التوكن من قاعدة البيانات .وايضا على اسم القناة وبهذا يمكننا ببساطة الانضمام إلى القناة في مكان آخر
    await callViewModel.rtcEngine.joinChannel(
        widget.callerInfo.token, widget.callerInfo.channelName!, null, 0);
  }
}
