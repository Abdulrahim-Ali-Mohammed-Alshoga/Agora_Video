import '../../constants/firebase.dart';

class Call{
  late String id;
  String? token;
 String? channelName;
  String? callerId;
  String? callerName;
 // String? callerAvatar;
  String? receiverId;
  String? receiverName;
 // String? receiverAvatar;
  String? stateCall;
  //num? createAt;
 // bool? current;

  Call.fromJson(json) {
    id = json[CallFire.id];
    callerId = json[CallFire.callerId];
    token = json[CallFire.token];
    channelName = json[CallFire.channelName];
    callerName = json[CallFire.callerName];
    receiverId = json[CallFire.receiverId];
    receiverName = json[CallFire.receiverName];
    stateCall = json[CallFire.stateCall];

  }
}