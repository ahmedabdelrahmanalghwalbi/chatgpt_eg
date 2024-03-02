import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import '../providers/authentication_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_widget.dart';

class AIChatStreamWidget extends StatelessWidget {
  const AIChatStreamWidget({
    super.key,
    required this.messagesController,
  });

  final ScrollController messagesController;

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthenticationProvider>().userModel.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: context.read<ChatProvider>().getChatStream(uid: uid),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.orangeAccent,
            ),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Chat is empty!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5),
            ),
          );
        }

        // automatic scroll down on new message
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          messagesController.jumpTo(messagesController.position.maxScrollExtent);
        });

        final messageSnapshot = snapshot.data!.docs;

        return ListView.builder(
          itemCount: messageSnapshot.length,
          controller: messagesController,
          itemBuilder: (context, index){
            return ChatWidget(
              messageData: messageSnapshot[index],
            );

          },
        );

      },
    );
  }
}