import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/repository/sing_in_repository.dart';

class SingInViewModel {
  TextEditingController controllerName = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPassword = TextEditingController();
  final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  AutovalidateMode autoValidateMode = AutovalidateMode.disabled;
  bool isPassword = true;
  late UserCredential credential;
  String textTitle = "Personal Information";
  String textDownTitle =
      "Let's know you better , this basic information is used to improve youre experience";
  String textFormName = "Name";
  String textFormNameError = "This is not  a valid name";
  String textFormEmail = "Email";
  String textFormEmailErrorOne = "'Email cannot be empty'";
  String textFormEmailErrorTow = "This is not Email";
  String textFormPassword = "Password";
  String textFormPasswordErrorOne = "This is not  a valid Password";
  String textFormPasswordErrorTow = "Password consist of 6 digits or more";
  String textSignIn = "SignIn";
  String textAlready = "Already have an account ! ";
  String textContinue = "Continue";
  SingInRepository singInRepository = SingInRepository();

  Future<void> setSingIn(
      {required String email,
      required String password,
      required String name}) async {
    await singInRepository.setSingIn(
        email: email, password: password, name: name);
  }

  get() {
    return singInRepository.id;
  }
}
