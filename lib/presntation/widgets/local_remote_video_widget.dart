import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:flutter/material.dart';
class LocalRemoteVideoWidget extends StatelessWidget {
  const LocalRemoteVideoWidget({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return
    const RtcLocalView.SurfaceView();
  }
}
