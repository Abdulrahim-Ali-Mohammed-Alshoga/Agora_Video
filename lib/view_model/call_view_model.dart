import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:permission_handler/permission_handler.dart';
import '../data/repository/call_repository.dart';

class CallViewModel {
  int remoteUid = 0;
  bool isMic = false;
  bool changLocalRender = false;
  bool isInitAgora = false;
  late RtcEngine rtcEngine;
  CallRepository callRepository = CallRepository();
  AudioPlayer assetsAudioPlayer = AudioPlayer();

//تعمل الدالة على تحديد مكان الملف الصوتي وتشغيلة وعند الانتهاء يتم تشغيلة مرة اخرى
  Future<void> playContactingRing() async {
    await assetsAudioPlayer.play(AssetSource('sounds/phone.mp3'));
    assetsAudioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> gatCallStream(String id) {
    return callRepository.gatCallStream(id: id, cut: "cutCaller");
  }


  permission() async {
    await [Permission.microphone, Permission.camera].request();
  }

  Future<void> updateCall(
      {required String stateCall, required String id}) async {
    return await callRepository.updateCall(stateCall: stateCall, id: id);
  }
}
