import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:chat_gpt_eg/widgets/message_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:grouped_list/grouped_list.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../providers/chat_provider.dart';

class CommentsStreamWidget extends StatelessWidget {
  const CommentsStreamWidget({
    Key? key,
    required this.messagesController,
    required this.postData,
  }) : super(key: key);

  final ScrollController messagesController;
  final dynamic postData;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: context
          .read<ChatProvider>()
          .getCommentsStream(postId: postData[Constants.postId]),
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
              'No comments yet!',
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
          messagesController
              .jumpTo(messagesController.position.maxScrollExtent);
        });

        final commentsSnapshot = snapshot.data!.docs;

        return GroupedListView<dynamic, DateTime>(
          controller: messagesController,
          elements: commentsSnapshot,
          padding: const EdgeInsets.all(8.0),
          reverse: true,
          groupBy: (element) {
            var date = element[Constants.messageTime] == null
                ? DateTime.now()
                : element[Constants.messageTime].toDate();

            DateTime dateTime = date;

            return DateTime(
              dateTime.year,
              dateTime.month,
              dateTime.day,
            );
          },
          groupHeaderBuilder: (dynamic groupByValue) => SizedBox(
            height: 40,
            child: Center(
              child: Card(
                color: Colors.deepPurple,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: groupByValue[Constants.messageTime] == null
                      ? Text(DateTime.now().toString())
                      : Text(
                          DateFormat.yMMMd()
                              .format(
                                  groupByValue[Constants.messageTime].toDate())
                              .toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
          itemBuilder: (context, dynamic element) {
            String uid = context.read<AuthenticationProvider>().userModel.uid;
            return Align(
              alignment: uid == element[Constants.senderId]
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: MessageWidget(
                element: element,
              ),
            );
          },
          groupComparator: (value1, value2) => value2.compareTo(value1),
          itemComparator: (item1, item2) {
            var firstItem = item1[Constants.messageTime] == null
                ? DateTime.now()
                : item1[Constants.messageTime].toDate();

            var secondItem = item2[Constants.messageTime] == null
                ? DateTime.now()
                : item2[Constants.messageTime].toDate();

            return secondItem.compareTo(firstItem);
          }, // optional
          useStickyGroupSeparators: true, // optional
          floatingHeader: true, // optional
          order: GroupedListOrder.ASC, // optional
        );
      },
    );
  }
}
