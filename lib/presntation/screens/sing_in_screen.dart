import 'package:agora_video/constants/name_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/text_form_field_widget.dart';

class SingInScreen extends StatefulWidget {
  const SingInScreen({Key? key}) : super(key: key);

  @override
  State<SingInScreen> createState() => _SingInScreenState();
}

class _SingInScreenState extends State<SingInScreen> {
  TextEditingController controllerPassword = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool isPassword = true;
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  // var box = Hive.box(authDb);
  Future<void> singInFill() async {
    if (globalKey.currentState!.validate()) {
      globalKey.currentState!.save();
      // await box.put(authTable, true);
      // await  box.put(typeAuthTable, true);
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: controllerEmail.text,
          password: controllerPassword.text,
        ).then((value){

          Navigator.pushNamedAndRemoveUntil(context, NamePage.homeScreen, (route) => false);

        });}on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      } catch (e) {
        print(e);
      }





    } else {
      setState(() {
        _autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        autovalidateMode: _autoValidateMode,
        key: globalKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 20, top: 50, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Text(
                  "Hello Again !",
                  style: TextStyle(
                      color:Colors.white,

                      fontSize: 25),
                ),
                SizedBox(height: 10),
                Text(
                  "Enter your E-mail & password to find out what's new",
                  style: TextStyle(
                      fontSize: 12,

                      color: Colors.grey),
                ),
                SizedBox(height: 60),
                TextFormFieldWidget(
                    controller: controllerEmail,
                    hintText: "Emile",
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Emile cannot be empty';
                      } else if (!value.contains("@")||!value.contains(".com")) {
                        return 'This is not Email';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.emailAddress),
                SizedBox(height: 20),
                TextFormFieldWidget(
                    controller: controllerPassword,
                    hintText: "Password",
                    obscureText: isPassword ? true : false,
                    suffixIcon: GestureDetector(
                        onTap: () {
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
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                    textInputType: TextInputType.name),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: RichText(
                      text: TextSpan(children: <WidgetSpan>[
                        WidgetSpan(
                            child: Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,

                              ),
                            )),
                        WidgetSpan(
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, NamePage.singUpScreen);
                              },
                              child: const Text("SignUp",
                                  style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 14,

                                  )),
                            )),
                      ])),
                ),
                SizedBox(
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
                          singInFill();
                        },
                        child: const Center(
                          child: Text(
                            "Continue",
                            style: TextStyle(
                                fontSize: 25,

                                color: Colors.white),
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}