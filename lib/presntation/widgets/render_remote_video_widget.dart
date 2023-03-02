import 'package:agora_video/constants/agora_manager.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
class RenderRemoteVideoWidget extends StatelessWidget {
   RenderRemoteVideoWidget({Key? key,required this.channelName,required this.remoteUid}) : super(key: key);
 int remoteUid;
 String channelName;
  @override
  Widget build(BuildContext context) {
    return  RtcRemoteView.SurfaceView(
      uid: remoteUid,
      channelId:channelName,
    );
  }
}
