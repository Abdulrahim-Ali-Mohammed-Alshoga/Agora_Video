class HomeScreenArgument{
  HomeScreenArgument({required this.id});
String id;
}
class VideoCallScreenArgument{

 String receiverId;
 String callerId;
 String callerName;
 String receiverName;
 VideoCallScreenArgument({required this.receiverName,required this.receiverId,required this.callerName,required this.callerId});
}