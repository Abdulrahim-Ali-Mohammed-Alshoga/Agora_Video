import 'dart:async';
import 'dart:ui';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_video/data/repository/call_repository.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/firebase.dart';
import '../data/models/call.dart';

class VideoCallViewModel {
  final callsFirebase =
      FirebaseFirestore.instance.collection(CallFire.callsCollections).doc();
  int remoteUid = 0;
  bool changLocalRender = false;
  bool isMic = false;
  bool playEffect = true;
  String callingOrRinging = "Calling...";
  late RtcEngine rtcEngine;
  AudioPlayer assetsAudioPlayer = AudioPlayer();
  int timerMaxSeconds = 40;
  int currentSeconds = 0;


  channelSuccess(
      {required VoidCallback addCall, required VoidCallback playRing}) {
    addCall;
    playRing;
  }

  Future<void> contactingRing(
      {required AudioPlayer audioPlayer, required String assetsAudio}) async {
    await audioPlayer.play(AssetSource(assetsAudio));
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';
  CallRepository callRepository = CallRepository();

  Stream<QuerySnapshot<Map<String, dynamic>>> gatCallStream() {
    return callRepository.gatCallStream(id: callsFirebase.id,cut:'cutReceiver' );
  }

  Future<void> updateCall({required String stateCall}) async {
    return await callRepository.updateCall(
        stateCall: stateCall, id: callsFirebase.id);
  }

  setCall(
      {required String channelName,
      required String token,
      required String callerName,
      required String receiverName,
      required String callerId,
      required String receiverId}) async {
    return await callRepository.setCall(
        fireBase: callsFirebase,
        call: Call(
            id: callsFirebase.id,
            channelName: channelName,
            callerName: callerName,
            callerId: callerId,
            receiverName: receiverName,
            receiverId: receiverId,
            token: token,
            stateCall: "calling"));
  }
}
