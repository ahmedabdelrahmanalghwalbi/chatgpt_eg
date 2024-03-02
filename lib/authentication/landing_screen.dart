import 'package:chat_gpt_eg/authentication/registration_screen.dart';
import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_screens/home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  void initState() {
    checkAuthentication();
    super.initState();
  }

  void checkAuthentication() async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    if (await authProvider.checkSignedIn()) {
      // get user data from fireStore
      await authProvider.getUserDataFromFireStore();

      // get data from shared preferences
      await authProvider.getUserDataFromSharedPref();

      // navigate to home
      navigate(isSingedIn: true);
    } else {
      // navigate to register screen
      navigate(isSingedIn: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.orangeAccent,
        ),
      ),
    );
  }

  void navigate({required bool isSingedIn}) {
    if (isSingedIn) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false);
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
          (route) => false);
    }
  }
}
