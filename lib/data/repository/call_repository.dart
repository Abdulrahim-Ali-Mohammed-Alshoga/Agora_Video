import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firebase.dart';
import '../models/call.dart';

class CallRepository {



  Future<void> updateCall({required String stateCall,required String id}) async {
    await FirebaseFirestore.instance
        .collection(CallFire.callsCollections)
        .doc(id)
        .update({
      CallFire.stateCall: stateCall,
    });
  }

  setCall(
      {
        required Call call,
      required DocumentReference<Map<String, dynamic>> fireBase,
      }) {
    fireBase.set(
      call.toMap()
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> gatCallStream({required String id,required String cut}) {
    return FirebaseFirestore.instance
        .collection(CallFire.callsCollections)
        .where(CallFire.stateCall, isEqualTo: cut)
        .where(CallFire.id, isEqualTo: id)
        .snapshots();
  }

}
