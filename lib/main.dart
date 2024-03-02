import 'package:chat_gpt_eg/authentication/landing_screen.dart';
import 'package:chat_gpt_eg/authentication/registration_screen.dart';
import 'package:chat_gpt_eg/authentication/user_information_screen.dart';
import 'package:chat_gpt_eg/constants/constants.dart';
// import 'package:chat_gpt_eg/firebase_options.dart';
import 'package:chat_gpt_eg/main_screens/home_screen.dart';
import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:chat_gpt_eg/providers/chat_provider.dart';
import 'package:chat_gpt_eg/providers/my_theme_provider.dart';
import 'package:chat_gpt_eg/themes/my_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  await dotenv.load(fileName: ".env");
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MyThemeProvider()),
    ChangeNotifierProvider(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider(create: (_) => ChatProvider())
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    getCurrentTheme();
    super.initState();
  }

  void getCurrentTheme() async {
    await Provider.of<MyThemeProvider>(context, listen: false).getThemeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MyThemeProvider>(
      builder: (BuildContext context, value, Widget? child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme:
              MyTheme.themeData(isDarkTheme: value.themeType, context: context),
          initialRoute: Constants.landingScreen,
          routes: {
            Constants.landingScreen: (context) => const LandingScreen(),
            Constants.registrationScreen: (context) =>
                const RegistrationScreen(),
            Constants.homeScreen: (context) => const HomeScreen(),
            Constants.userInformationScreen: (context) =>
                const UserInformationScreen(),
          },
        );
      },
    );
  }
}
