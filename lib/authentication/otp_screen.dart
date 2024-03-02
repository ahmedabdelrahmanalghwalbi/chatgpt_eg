import 'package:chat_gpt_eg/authentication/user_information_screen.dart';
import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../main_screens/home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  const OTPScreen({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? smsCode;
  @override
  Widget build(BuildContext context) {
    final authRepo = Provider.of<AuthenticationProvider>(context, listen: true);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),

                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(90)),
                    child: const CircleAvatar(
                      radius: 80,
                      child: Icon(
                        Icons.interpreter_mode_sharp,
                        size: 70,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Verification',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Enter the OPT code sent to your phone number',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // pinput
                  Pinput(
                    length: 6,
                    showCursor: true,
                    defaultPinTheme: PinTheme(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.deepPurple),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    onCompleted: (value) {
                      setState(() {
                        smsCode = value;
                      });

                      // verify OTP
                      verifyOTP(smsCode: smsCode!);
                    },
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  authRepo.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.orangeAccent,
                        )
                      : const SizedBox.shrink(),

                  authRepo.isSuccessful
                      ? Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green,
                          ),
                          child: const Icon(
                            Icons.done,
                            color: Colors.white,
                            size: 30,
                          ),
                        )
                      : const SizedBox.shrink(),

                  const SizedBox(
                    height: 25,
                  ),

                  const Text(
                    'Didn\'t receive any code?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Text(
                    'Resend new code',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verifyOTP({required String smsCode}) {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    authProvider.verifyOTP(
      context: context,
      verificationId: widget.verificationId,
      smsCode: smsCode,
      onSuccess: () async {
        // 1. check database if the current user exist
        bool userExits = await authProvider.checkUserExist();
        if (userExits) {
          // 2. get user data from database
          await authProvider.getUserDataFromFireStore();
          // 3. save user data to shared preferences
          await authProvider.saveUserDataToSharedPref();
          // 4. save this user as signed in
          await authProvider.setSignedIn();
          // 5. navigate to Home
          navigate(isSingedIn: true);
        } else {
          // navigate to user information screen
          navigate(isSingedIn: false);
        }
      },
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserInformationScreen()));
    }
  }
}
