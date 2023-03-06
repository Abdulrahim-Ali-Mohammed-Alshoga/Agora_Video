import '../../constants/firebase.dart';

class Call {
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
  Call(
      {required this.id,
      required this.channelName,
      required this.token,
      required this.callerName,
      required this.stateCall,
      required this.receiverName,
      required this.receiverId,
      required this.callerId});

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

  Map<String, dynamic> toMap() {
    return {
      CallFire.id: id,
      CallFire.callerId: callerId,
      CallFire.token: token,
      CallFire.channelName: channelName,
      CallFire.callerName: callerName,
      CallFire.receiverId: receiverId,
      CallFire.receiverName: receiverName,
      CallFire.stateCall: stateCall
    };
  }
}
