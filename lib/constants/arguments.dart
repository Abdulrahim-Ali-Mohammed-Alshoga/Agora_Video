import '../data/models/call.dart';

class HomeScreenArgument {
  HomeScreenArgument({required this.id});

  String id;
}

class VideoCallScreenArgument {
  String receiverId;
  String callerId;
  String token;
  String channelName;
  String callerName;
  String receiverName;

  VideoCallScreenArgument(
      {required this.receiverName,
      required this.receiverId,
      required this.token,
      required this.channelName,
      required this.callerName,
      required this.callerId});
}

class CallScreenArgument {
  CallScreenArgument({required this.callerInfo});

  Call callerInfo;
}
