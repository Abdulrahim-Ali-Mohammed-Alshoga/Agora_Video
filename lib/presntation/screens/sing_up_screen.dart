import 'package:agora_video/constants/firebase.dart';
import 'package:agora_video/constants/name_page.dart';
import 'package:agora_video/view_model/sing_in_view_model.dart';
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
  SingInViewModel singInViewModel = SingInViewModel();

  // var box = Hive.box(authDb);
  Future<void> personalInfoFill() async {
    if (singInViewModel.globalKey.currentState!.validate()) {
      singInViewModel.globalKey.currentState!.save();
      // await box.put(authTable, true);
      // await  box.put(typeAuthTable, false);
      singInViewModel
          .setSingIn(
              email: singInViewModel.controllerEmail.text,
              password: singInViewModel.controllerPassword.text,
              name: singInViewModel.controllerName.text)
          .then((value) => Navigator.pushNamedAndRemoveUntil(
              context,
              arguments: HomeScreenArgument(id: singInViewModel.get()),
              NamePage.homeScreen,
              (route) => false))
          .catchError((error) => print("Failed to add user: $error"));
      // Navigator.pushNamed(context, signUpScreen, arguments: {
      //   'name': name.text,
      //   'phoneNumber': phoneNumber.text,
      //   'address': address.text,
      //   'image': image
      // });
    } else {
      setState(() {
        singInViewModel.autoValidateMode = AutovalidateMode.always;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Form(
        autovalidateMode: singInViewModel.autoValidateMode,
        key: singInViewModel.globalKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, top: 40, right: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  singInViewModel.textTitle,
                  style: const TextStyle(fontSize: 25, color: Colors.black),
                ),
                const SizedBox(height: 10),
                Text(
                  singInViewModel.textDownTitle,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
                const SizedBox(height: 60),
                TextFormFieldWidget(
                    controller: singInViewModel.controllerName,
                    hintText: singInViewModel.textFormName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return singInViewModel.textFormNameError;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.name),
                const SizedBox(height: 20),
                TextFormFieldWidget(
                    controller: singInViewModel.controllerPassword,
                    hintText: singInViewModel.textFormPassword,
                    obscureText: singInViewModel.isPassword ? true : false,
                    suffixIcon: GestureDetector(
                        onTap: () {
                          print(55);
                          setState(() {
                            singInViewModel.isPassword =
                                !singInViewModel.isPassword;
                          });
                        },
                        child: Icon(
                          singInViewModel.isPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          // size: 20,
                          color: Colors.white,
                        )),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return singInViewModel.textFormPasswordErrorOne;
                      } else if (value.length <= 6) {
                        return singInViewModel.textFormPasswordErrorTow;
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text),
                const SizedBox(height: 20),
                TextFormFieldWidget(
                    controller: singInViewModel.controllerEmail,
                    hintText: singInViewModel.textFormEmail,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return singInViewModel.textFormEmailErrorOne;
                      } else if (!value.contains("@") ||
                          !value.contains(".com")) {
                        return singInViewModel.textFormEmailErrorTow;
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
                      WidgetSpan(
                          child: Text(
                        singInViewModel.textAlready,
                        style: const TextStyle(
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
                        child: Text(singInViewModel.textSignIn,
                            style: const TextStyle(
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
                        child: Center(
                          child: Text(
                            singInViewModel.textContinue,
                            style: const TextStyle(
                                fontSize: 25, color: Colors.white),
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
