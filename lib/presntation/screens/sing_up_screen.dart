import 'package:agora_video/constants/firebase.dart';
import 'package:agora_video/constants/name_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../constants/arguments.dart';
import '../widgets/text_form_field_widget.dart';

class SingUpScreen extends StatefulWidget {
  const SingUpScreen({Key? key}) : super(key: key);

  @override
  State<SingUpScreen> createState() => _SingUpScreenState();
}

class _SingUpScreenState extends State<SingUpScreen> {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  bool isPassword = true;
   late UserCredential credential;
   late String id;


  // var box = Hive.box(authDb);
  Future<void> personalInfoFill() async {
    if (globalKey.currentState!.validate()) {
      globalKey.currentState!.save();
      // await box.put(authTable, true);
      // await  box.put(typeAuthTable, false);


      try {
          await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: controllerEmail.text,
          password: controllerPassword.text,
        )
            .then((value) {
              id=value.user!.uid;
          users
              .add({
            UserFire.name: controllerName.text.trim(), // John Doe
            UserFire.email: controllerEmail.text.trim(), // Stokes and Sons
            UserFire.password: controllerPassword.text.trim(), // Stokes and Sons
            UserFire.id: id, // Stokes and Sons
          })
              .then((value) => Navigator.pushNamedAndRemoveUntil(
              context, arguments: HomeScreenArgument(id: id), NamePage.homeScreen, (route) => false))
              .catchError((error) => print("Failed to add user: $error"));

        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }
      // Navigator.pushNamed(context, signUpScreen, arguments: {
      //   'name': name.text,
      //   'phoneNumber': phoneNumber.text,
      //   'address': address.text,
      //   'image': image
      // });
    } else {
      setState(() {
        autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        autovalidateMode: autoValidateMode,
        key: globalKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Personal Information",
                  style: TextStyle(fontSize: 25, color: Colors.black),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Let's know you better , this basic information is used to improve youre experience",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 60),
                TextFormFieldWidget(
                    controller: controllerName,
                    hintText: "Name",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This is not  a valid name';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.name),
                const SizedBox(height: 20),
                TextFormFieldWidget(
                    controller: controllerPassword,
                    hintText: "Password",
                    obscureText: isPassword ? true : false,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          print(55);
                          setState(() {
                            isPassword = !isPassword;
                          });
                        },
                        child: Icon(
                          isPassword ? Icons.visibility : Icons.visibility_off,
                          // size: 20,
                          color: Colors.white,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'This is not  a valid Password';
                      } else if (value.length <= 6) {
                        return 'Password consist of 6 digits or more';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text),
                const SizedBox(height: 20),
                TextFormFieldWidget(
                    controller: controllerEmail,
                    hintText: "Email",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Email cannot be empty';
                      } else if (!value.contains("@") ||
                          !value.contains(".com")) {
                        return 'This is not Email';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.name),
                const SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                        text: TextSpan(children: <WidgetSpan>[
                      const WidgetSpan(
                          child: Text(
                        "Already have an account ! ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      )),
                      WidgetSpan(
                          child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          //  Navigator.pushNamedAndRemoveUntil(context, singInScreen, (route) => false);
                        },
                        child: const Text(" SignIn",
                            style: TextStyle(
                              color: Colors.deepOrange,
                              fontSize: 12,
                            )),
                      )),
                    ])),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                SizedBox(
                  height: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange),
                        onPressed: () {
                          personalInfoFill();
                        },
                        child: const Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                        )),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
