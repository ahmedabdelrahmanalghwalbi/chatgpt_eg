import 'package:chat_gpt_eg/constants/constants.dart';
import 'package:chat_gpt_eg/widgets/ai_chat_stream_widget.dart';
import 'package:chat_gpt_eg/widgets/comments_stream_widget.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key, required this.fromScreen, this.postData})
      : super(key: key);

  final FromScreen fromScreen;
  final dynamic postData;

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final ScrollController messagesController = ScrollController();

  @override
  void dispose() {
    messagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.fromScreen == FromScreen.aIChatScreen
        ? AIChatStreamWidget(messagesController: messagesController)
        : CommentsStreamWidget(
            messagesController: messagesController, postData: widget.postData);
  }
}
