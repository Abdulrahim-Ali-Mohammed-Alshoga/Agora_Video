
import '../../constants/firebase.dart';

class Users {
   String? name;
   String? id;
   String? password;
   String? email;
  Users({this.name, this.id,this.password,this.email});

   factory Users.fromJson(jsonData) {
   return Users(name: jsonData[UserFire.name],email: jsonData[UserFire.email], id: jsonData['id'],password:jsonData[UserFire.password] );
  }
   Map<String, dynamic> toMap() {
     return {
       UserFire.name: name,
       UserFire.id: id,
       UserFire.password: password,
       UserFire.email: email,
     };
   }
}
