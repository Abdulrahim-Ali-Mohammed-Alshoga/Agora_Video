import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_video/view_model/video_call_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/agora_manager.dart';
import '../../constants/arguments.dart';
import '../widgets/local_remote_video_widget.dart';
import '../widgets/render_remote_video_widget.dart';

class VideoCallScreen extends StatefulWidget {
  VideoCallScreen({Key? key, required this.videoCSA}) : super(key: key);

  // يتم في هذا المتغير احتواء معلومات خاص بالتصال وقاعدة البيانات قادمة من الصفحة الرئيسية مثل رقم id لكل من المتصل والمستقبل اسماهم والتوكن واسم القناة
  VideoCallScreenArgument videoCSA;

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  VideoCallViewModel videoCallViewModel = VideoCallViewModel();

//يتم في هذه الدالة الاستماع للمستقبل اذا رفض المكالة قبل ان يرتبط

  callStream() {
    videoCallViewModel.gatCallStream().listen((value) {
      if (value.docs.isNotEmpty) {
        Navigator.pop(context);
      }
    });
  }

//تشغيل الاتصال  وبداء الاستماع لقاعدة البيانات
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAgora();
    callStream();
  }

//يتم قطع قناة الاتصال وايضا الرنة وتحديث قاعدة البيانات بان الاتصال انتهاء من خلات تغير stateCall المتعلقة به  بهذا الاتصال الى endCalling
  //قطع الاتصال اي من الطرفين المتصل و المستقبل والرجوع الى الصفحة السابقة
  @override
  void dispose() {
    // TODO: implement dispose
    videoCallViewModel.rtcEngine.destroy();
    videoCallViewModel.assetsAudioPlayer.dispose();
    videoCallViewModel.updateCall(stateCall: "endCalling");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            //المتغير remoteUid قمنا بعملة لكي اذا قبل المستقبل الاتصال تتغير الوجة الى واجهة الاتصال اذا كان المتغير لا يسوي 0 واذا سوت 0 تكون وجهة حق الرنة
            child: videoCallViewModel.remoteUid == 0
                ? Stack(
                    children: [
                      //هنا يتم عرض الكاميرة الامامية للمستخدم
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
                                    // اسم المستقبل
                                    text: widget.videoCSA.receiverName,
                                    style: const TextStyle(
                                        fontSize: 25,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold)),
                                TextSpan(
                                    text:
                                        //يحتوي هذا المتغير على calling فاذا تم الاتصال اي قبل ان يرتبط مع المستقبل يتغير النص الى تحويل Ringing
                                        '\n${videoCallViewModel.callingOrRinging}',
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
                      //هذا المتغير من اجل التغيير بين الشاشتيين الكبيرة والصغيرة
                      videoCallViewModel.changLocalRender
                          //هنا يتم عرض الكاميرة  للمتصل في الشاشة الكبيرة اذا المتغير changLocalRender يساوي true
                          ? const LocalRemoteVideoWidget()
                          //  هنا يتم عرض الكاميرة للمستقبل في الشاشة الكبيرة  اذا المتغير changLocalRender يساوي false
                          : RenderRemoteVideoWidget(
                              channelName: widget.videoCSA.channelName,
                              remoteUid: videoCallViewModel.remoteUid),
                      SafeArea(
                        child: Align(
                          alignment: Alignment.topRight,
                          //هنا يتم عرض الوقت المتبقي للاتصال
                          child: Text(videoCallViewModel.timerText,
                              style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            //هنا يتم امر التبديل بين الشاشتين الكبيرة و الصغيرة
                            videoCallViewModel.changLocalRender =
                                !videoCallViewModel.changLocalRender;
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
                              child: videoCallViewModel.changLocalRender
                                  //هنا يتم عرض الكاميرة للمتصل في الشاشة الصغيرة  اذا المتغير changLocalRender يساوي false
                                  ? RenderRemoteVideoWidget(
                                      channelName: widget.videoCSA.channelName,
                                      remoteUid: videoCallViewModel.remoteUid)
                                  //هنا يتم عرض الكاميرة للمستقبل في الشاشة الصغيرة اذا المتغير changLocalRender يساوي true
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
                      fillColor: videoCallViewModel.isMic
                          ? Colors.blueAccent
                          : Colors.white,
                      shape: const CircleBorder(),
                      elevation: 2,
                      onPressed: () {
                        setState(() {
                          //هنا يتم امر التبديل بين كتم الصوت وفتحة
                          videoCallViewModel.isMic = !videoCallViewModel.isMic;
                        });
                        videoCallViewModel.rtcEngine.muteAllRemoteAudioStreams(
                            videoCallViewModel.isMic);
                      },
                      child: Icon(
                        //هنا يتم تبديل بين الايقونة بين ايقونة كتم وفتح الصوت
                        videoCallViewModel.isMic ? Icons.mic_off : Icons.mic,
                        //هنا يتم تبديل الالوان الايقونة
                        color: videoCallViewModel.isMic
                            ? Colors.white
                            : Colors.blueAccent,
                        size: 30,
                      )),
                  RawMaterialButton(
                      elevation: 2,
                      onPressed: () {
                        //يتم قطع قناة الاتصال وايضا الرنة وتحديث قاعدة البيانات بان الاتصال انتهاء من قبل المتصل وقطع الاتصال اذا كان المستقبل في حالة الرنة بحيث يتم تغيير stateCall المتعلقة بهذا الاتصال الى citCaller
                        videoCallViewModel.updateCall(stateCall: "citCaller");
                        videoCallViewModel.rtcEngine.leaveChannel();
                        //قطع الاتصال اي من الطرفين المتصل و المستقبل والرجوع الى الصفحة السابقة
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
                        videoCallViewModel.rtcEngine.switchCamera();
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

//يتم في هذه الدالة انشاء مكالة والمعلومات المتعلقة بها في قاعدة البيانات
  addCallFire() {
    videoCallViewModel.setCall(
        channelName: widget.videoCSA.channelName,
        token: widget.videoCSA.token,
        callerName: widget.videoCSA.callerName,
        receiverName: widget.videoCSA.receiverName,
        callerId: widget.videoCSA.callerId,
        receiverId: widget.videoCSA.receiverId);
  }

// هذه الدالة تتعامل مع جميع عمليات الاتصال
  Future<void> initAgora() async {
    startTimeout();
    // await [Permission.microphone, Permission.camera].request();
    videoCallViewModel.rtcEngine = await RtcEngine.create(AgoraManager.appId);
    //هذا الامر يسمح بتشغيل خاصية الفيديو
    videoCallViewModel.rtcEngine.enableVideo();
    videoCallViewModel.rtcEngine.setEventHandler(
      RtcEngineEventHandler(
        //تعمل الدالة عند ما يتم محاولة الارتباط اي قبل ما تتم عملية الاتصال وبداء المحادثة
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          // ظظنقوم بتشغيل الرنه ونعمل على تحويل النص من calling الى Ringing وايضا نحفظ الاتصال في قاعدة البيانات ووقت للاتصال مدتة 70 ثانية فاذا لم يتن الرذ يقطع الاتصال
          playContactingRing();
          addCallFire();
          videoCallViewModel.callingOrRinging = 'Ringing';
          setState(() {
            //هنا يتم امر تغيير قيمة currentSeconds الى صفر وفي هذا المتغير يتم الزيادة فيه كل ثانية ب1 حتي يصل الى 70 فيتم قطع الاتصال
            videoCallViewModel.currentSeconds = 0;
            videoCallViewModel.timerMaxSeconds = 70;
          });
        },
        //تعمل الدالة عندما يتم بداء الاتصال بين الطرفين
        userJoined: (int uid, int elapsed) async {
// player.stop();
          //print('remote user $uid joined successfully');
//قمنا بقطع الرنة وخلينا مدة الاتصال 30 دقيقة وايضا تحويل المتغير remoteUid الى رقم غير 0 من اجل تتغير الوججه الى واجهه المحادثة بين الطرفين
          videoCallViewModel.assetsAudioPlayer.stop();
          //هنا يتم امر تغيير قيمة currentSeconds الى صفر وفي هذا المتغير يتم الزيادة فيه كل ثانية ب1 حتي يصل الى 70 فيتم قطع الاتصال
          videoCallViewModel.currentSeconds = 0;
          videoCallViewModel.timerMaxSeconds = 1800;
          setState(() => videoCallViewModel.remoteUid = uid);
        },
        //تعمل الدالة عندما يقوم المستقبل اي الطرف الاخر بقطع الاتصال
        //يتم قطع الرنة والاتصال بين الطرفين والرجوع الى الصفحة السابقة وايضا تحويل المتغير remoteUid الى 0
        //المتغير remoteUid قمنا بعملة لكي اذا قبل المستقبل الاتصال تتغير الوجة الى واجهة الاتصال اذا كان المتغير لا يسوي 0 واذا سوت 0 تكون وجهة حق الرنة
        userOffline: (int uid, UserOfflineReason reason) async {
          // print('remote user $uid left call');
          setState(() => videoCallViewModel.remoteUid = 0);
          await videoCallViewModel.assetsAudioPlayer.stop();
          Navigator.of(context).pop();
        },
      ),
    );
    //تشغيل الكاميرا اول ما ندخل الصفحة يعني قبل حتى ما تشتغل دالة joinChannelSuccess
    await videoCallViewModel.rtcEngine.startPreview();
    //آخر شيء في وظيفة rtcEngine ، نحتاج إلى ضم المتصل إلى القناة. أولاً ، يجب  توفير الرمز المميز التوكن للاتصال ، من خلال إنشاء خادم لتوليد الرمز وانشاء اسم للقناة ويمكنك للمستقبل استعمال قاعدة البيانات للوصول للتوكن و اسم قناة. فعندما نحصل على الرمز المميز و اسم القناة، يمكننا ببساطة الانضمام إلى القناة في مكان آخر ويمكنك أيضًا إنشاء رمز مميز مؤقت لاسم قناة معين على لوحة معلومات agora للاختبار.
    await videoCallViewModel.rtcEngine.joinChannel(
        widget.videoCSA.token, widget.videoCSA.channelName, null, 0);
  }

// يتم في هذه الدالة حساب الوقت التنازلي الذي يعطى للمتغير timerMaxSeconds واذا انتهاء يتم قطع القناة والرجوع للصفحة السابقة
  startTimeout() {
    var duration = const Duration(seconds: 1);
    Timer.periodic(duration, (timer) {
      setState(() {
        videoCallViewModel.currentSeconds = timer.tick;
        if (timer.tick >= videoCallViewModel.timerMaxSeconds) {
          timer.cancel();
          videoCallViewModel.rtcEngine.leaveChannel();
          // قطع الاتصال اي من الطرفين المتصل و المستقبل والرجوع الى الصفحة السابقة عند نفاذ الوقت
          Navigator.of(context).pop(true);
        }
      });
    });
  }

//تعمل الدالة على تحديد مكان الملف الصوتي وتشغيلة وعند الانتهاء يتم تشغيلة مرة اخرى
  Future<void> playContactingRing() async {
    videoCallViewModel.contactingRing(
        audioPlayer: videoCallViewModel.assetsAudioPlayer,
        assetsAudio: 'sounds/phone_calling_Sound_Effect.mp3');
  }
}
