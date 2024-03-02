import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_gpt_eg/authentication/registration_screen.dart';
import 'package:chat_gpt_eg/providers/chat_provider.dart';
import 'package:chat_gpt_eg/service/image_cache_manager.dart';
import 'package:chat_gpt_eg/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/authentication_provider.dart';
import '../providers/my_theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  showLogOutDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Log Out',
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'Are you sure to logout?',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () async {
                  // logout
                  await context.read<AuthenticationProvider>().signOutUser();
                  navigateToRegisterScreen();
                },
                child: const Text(
                  'Yes',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final themeStatus = Provider.of<MyThemeProvider>(context);
    Color color = themeStatus.themeType ? Colors.white : Colors.black;
    final chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Center(
          child: Text(
            'Account',
            style: TextStyle(color: color),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
            child: Consumer<AuthenticationProvider>(
              builder: (BuildContext context, value, Widget? child) {
                return Column(
                  children: [
                    Center(
                        child: Stack(
                      children: [
                        CircleAvatar(
                          key: UniqueKey(),
                          radius: 60,
                          backgroundColor: Colors.deepPurple,
                          backgroundImage: CachedNetworkImageProvider(
                              value.userModel.profilePic,
                              cacheManager:
                                  MyImageCacheManager.profileCacheManager),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,
                              border: Border.all(width: 2, color: Colors.white),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(35)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          // user name
                          Text(
                            value.userModel.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: color),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            value.userModel.phone,
                            style: TextStyle(color: color),
                          ),
                          const SizedBox(
                            height: 25,
                          ),
                          IntrinsicHeight(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Expanded(
                                    child: buildButton(
                                  context: context,
                                  value: '5',
                                  text: 'Shared',
                                )),
                                SizedBox(
                                  height: 24,
                                  child: VerticalDivider(
                                    color: color,
                                  ),
                                ),
                                Expanded(
                                    child: buildButton(
                                  context: context,
                                  value: '18',
                                  text: 'Following',
                                )),
                                SizedBox(
                                  height: 24,
                                  child: VerticalDivider(
                                    color: color,
                                  ),
                                ),
                                Expanded(
                                    child: buildButton(
                                  context: context,
                                  value: '25',
                                  text: 'Followers',
                                )),
                              ],
                            ),
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          Text(
                            'Account Settings',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: color),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          Divider(
                            color: color,
                            thickness: 0.5,
                          ),

                          SwitchListTile(
                              title: const Text(
                                'Speech',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              secondary: Icon(chatProvider.shouldSpeak
                                  ? Icons.mic
                                  : Icons.mic_off),
                              value: chatProvider.shouldSpeak,
                              onChanged: (value) {
                                chatProvider.setShouldSpeak(speak: value);
                              }),

                          Divider(
                            color: color,
                            thickness: 0.5,
                          ),

                          SwitchListTile(
                              title: const Text(
                                'Theme',
                                style: TextStyle(fontWeight: FontWeight.normal),
                              ),
                              secondary: Icon(
                                themeStatus.themeType
                                    ? Icons.dark_mode_outlined
                                    : Icons.light_mode_outlined,
                              ),
                              value: themeStatus.themeType,
                              onChanged: (value) {
                                themeStatus.setTheme = value;
                              }),
                          Divider(
                            color: color,
                            thickness: 0.5,
                          ),
                          InkWell(
                            onTap: () async {
                              showLogOutDialog();
                            },
                            child: const ListTile(
                              title: Text(
                                'Logout',
                                style: TextStyle(color: Colors.red),
                              ),
                              leading: Icon(
                                Icons.logout,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          Divider(
                            color: color,
                            thickness: 0.5,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void navigateToRegisterScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
        (route) => false);
  }
}
