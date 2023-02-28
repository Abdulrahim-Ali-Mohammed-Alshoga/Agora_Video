class Call{
  late String id;
  String? token;
  String? channelName;
  String? callerId;
  String? callerName;
  String? callerAvatar;
  String? receiverId;
  String? receiverName;
  String? receiverAvatar;
  String? status;
  num? createAt;
  bool? current;

  Call.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    token = json['token'];
    channelName = json['channelName'];
    callerId = json['callerId'];
    callerName = json['callerName'];
    callerAvatar = json['callerAvatar'];
    receiverId = json['receiverId'];
    receiverName = json['receiverName'];
    receiverAvatar = json['receiverAvatar'];
    status = json['status'];
    createAt = json['createAt'];
    current = json['current'];
  }
}