import 'package:chat_gpt_eg/constants/constants.dart';
import 'package:chat_gpt_eg/providers/chat_provider.dart';
import 'package:chat_gpt_eg/service/assets_manager.dart';
import 'package:chat_gpt_eg/widgets/bottom_chat_field.dart';
import 'package:chat_gpt_eg/widgets/chat_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../providers/my_theme_provider.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({Key? key}) : super(key: key);

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
    final chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 80,
            child: Icon(
              Icons.interpreter_mode_sharp,
              size: 20,
            ),
          ),
        ),
        title: Text(
          'ChapGPT',
          style: TextStyle(color: color),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<ChatProvider>().setIsText(textMode: true);
            },
            icon: Icon(
              Icons.chat,
              color: chatProvider.isText ? color : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<ChatProvider>().setIsText(textMode: false);
            },
            icon: Icon(
              Icons.image,
              color: !chatProvider.isText ? color : Colors.grey,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: ChatList(
                fromScreen: FromScreen.aIChatScreen,
              ),
            ),
            if (chatProvider.isTyping) ...[
              SpinKitDoubleBounce(
                color: color,
                size: 18,
              ),
            ],
            if (chatProvider.isListening) ...[
              Lottie.asset(AssetsManager.aiListening)
            ],
            const SizedBox(
              height: 10,
            ),
            const BottomChatField(
              fromScreen: FromScreen.aIChatScreen,
            ),
          ],
        ),
      ),
    );
  }
}
