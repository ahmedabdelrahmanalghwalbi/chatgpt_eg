import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';

class MessageWidget extends StatelessWidget {
  const MessageWidget({Key? key, required this.element}) : super(key: key);

  final dynamic element;

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = element[Constants.messageTime] == null
        ? DateTime.now()
        : element[Constants.messageTime].toDate();
    var time = formatDate(dateTime, [hh, ':', nn, ' ']);
    final userModel = context.read<AuthenticationProvider>().userModel;
    var senderId = element[Constants.senderId];
    return senderId == userModel.uid
        ? Container(
            constraints: const BoxConstraints(maxWidth: 350, minWidth: 80),
            margin: const EdgeInsets.only(top: 4, bottom: 4),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Padding(
                //   padding: const EdgeInsets.only(right: 8.0, top: 4.0, left: 8.0),
                //   child: Text(userModel.uid == senderId
                //       ?  'You'
                //       : element[Constants.senderName], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                // ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10, top: 5, bottom: 20),
                      child: Text(element[Constants.message],
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white)),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Text(
                        time,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.white60),
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        : Container(
            constraints: const BoxConstraints(maxWidth: 350, minWidth: 80),
            margin: const EdgeInsets.only(top: 4, bottom: 4),
            decoration: const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(right: 8.0, top: 4.0, left: 8.0),
                  child: Text(
                    element[Constants.senderName],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 30, top: 5, bottom: 20),
                      child: Text(element[Constants.message],
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black)),
                    ),
                    Positioned(
                      bottom: 4,
                      left: 10,
                      child: Text(
                        time,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black54),
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
  }
}
