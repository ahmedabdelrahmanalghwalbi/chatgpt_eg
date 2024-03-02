import 'dart:convert';
import 'dart:io';
import 'package:chat_gpt_eg/authentication/otp_screen.dart';
import 'package:chat_gpt_eg/constants/constants.dart';
import 'package:chat_gpt_eg/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility/utility.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isSuccessful = false;
  bool _isSignedIn = false;
  String? _uid;
  String? _phoneNumber;
  UserModel? _userModel;
  UserModel get userModel => _userModel!;
  String? get uid => _uid;
  String get phoneNumber => _phoneNumber!;
  bool get isSuccessful => _isSuccessful;
  bool get isLoading => _isLoading;
  bool get isSignedIn => _isSignedIn;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // sign in user with phone
  void signInWithPhone({
    required BuildContext context,
    required String phoneNumber,
    required RoundedLoadingButtonController btnController,
  }) async {
    try {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception(e.toString());
        },
        codeSent: (String verificationId, int? resendToken) {
          _phoneNumber = phoneNumber;
          notifyListeners();
          btnController.success();

          Future.delayed(const Duration(seconds: 1)).whenComplete(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OTPScreen(
                  verificationId: verificationId,
                ),
              ),
            );
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseException catch (e) {
      // show error message to user
      btnController.reset();
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String smsCode,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      User? user =
          (await firebaseAuth.signInWithCredential(phoneAuthCredential)).user;

      if (user != null) {
        _uid = user.uid;
        notifyListeners();
        onSuccess();
      }

      _isLoading = false;
      _isSuccessful = true;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  // save user data to fireStore database
  void saveUserDataToFireStore({
    required BuildContext context,
    required UserModel userModel,
    required File fileImage,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      // upload image to storage
      String imageUrl = await storeFileImageToStorage(
          '${Constants.userImages}/$uid.jpg', fileImage);
      userModel.profilePic = imageUrl;
      userModel.lastSeen = DateTime.now().microsecondsSinceEpoch.toString();
      userModel.dateJoined = DateTime.now().microsecondsSinceEpoch.toString();

      _userModel = userModel;

      // save data to fireStore
      await firebaseFirestore
          .collection(Constants.users)
          .doc(_uid)
          .set(userModel.toMap())
          .then((value) {
        onSuccess();
        _isLoading = false;
        notifyListeners();
      });
    } on FirebaseException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  // store image to firestore and get download URL
  Future<String> storeFileImageToStorage(String ref, File file) async {
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // check if user exits
  Future<bool> checkUserExist() async {
    DocumentSnapshot documentSnapshot =
        await firebaseFirestore.collection(Constants.users).doc(_uid).get();

    if (documentSnapshot.exists) {
      return true;
    } else {
      return false;
    }
  }

  // get user data from fireStore
  Future getUserDataFromFireStore() async {
    await firebaseFirestore
        .collection(Constants.users)
        .doc(firebaseAuth.currentUser!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      _userModel = UserModel(
        uid: documentSnapshot[Constants.uid],
        name: documentSnapshot[Constants.name],
        profilePic: documentSnapshot[Constants.profilePic],
        phone: documentSnapshot[Constants.phone],
        aboutMe: documentSnapshot[Constants.aboutMe],
        lastSeen: documentSnapshot[Constants.lastSeen],
        dateJoined: documentSnapshot[Constants.dateJoined],
        isOnline: documentSnapshot[Constants.isOnline],
      );
      _uid = _userModel!.uid;
      notifyListeners();
    });
  }

  // store user data to shared preference
  Future saveUserDataToSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(
        Constants.userModel, jsonEncode(userModel.toMap()));
  }

  // store user data to shared preference
  Future getUserDataFromSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String data = sharedPreferences.getString(Constants.userModel) ?? '';

    _userModel = UserModel.fromMap(jsonDecode(data));
    _uid = _userModel!.uid;

    notifyListeners();
  }

  Future setSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(Constants.isSignedIn, true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future<bool> checkSignedIn() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    _isSignedIn = sharedPreferences.getBool(Constants.isSignedIn) ?? false;
    notifyListeners();
    return _isSignedIn;
  }

  Future signOutUser() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await firebaseAuth.signOut();
    _isSignedIn = false;
    sharedPreferences.clear();
  }
}
