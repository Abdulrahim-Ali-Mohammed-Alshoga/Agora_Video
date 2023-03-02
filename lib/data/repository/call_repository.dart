

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../constants/firebase.dart';

class CallRepository{
 static updateCall({required String id, required String stateCall}) async {
   FirebaseFirestore.instance.collection(CallFire.callsCollections).doc(id).update({
    CallFire.stateCall:stateCall,
  });
  }
}