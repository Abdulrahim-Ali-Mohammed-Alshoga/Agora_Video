import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firebase.dart';
import '../models/call.dart';

class CallRepository {

  late Call call;
  final callsFirebase = FirebaseFirestore.instance.collection(CallFire.callsCollections).doc();
  Future<void> updateCall({required String stateCall}) async {
    await FirebaseFirestore.instance
        .collection(CallFire.callsCollections)
        .doc(callsFirebase.id)
        .update({
      CallFire.stateCall: stateCall,
    });
  }

  setCall(
      {required String channelName,
      required String token,
      required String callerName,
      required String receiverName,
      required String callerId,
      required String receiverId}) {
    call = Call(
        id: callsFirebase.id,
        channelName: channelName,
        token: token,
        callerName: callerName,
        stateCall: "calling",
        receiverName: receiverName,
        receiverId: receiverId,
        callerId: callerId);
    callsFirebase.set(
      call.toMap()
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> gatCallStream() {
    return FirebaseFirestore.instance
        .collection(CallFire.callsCollections)
        .where(CallFire.stateCall, isEqualTo: 'citReceiver')
        .where(CallFire.id, isEqualTo: callsFirebase.id)
        .snapshots();
  }
}
