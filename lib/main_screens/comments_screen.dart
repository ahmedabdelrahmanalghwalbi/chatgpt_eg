import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_gpt_eg/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../providers/my_theme_provider.dart';
import '../service/image_cache_manager.dart';
import '../widgets/bottom_chat_field.dart';
import '../widgets/chat_list.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key? key, required this.postData}) : super(key: key);

  final dynamic postData;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
    final chatProvider = context.watch<ChatProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            color: color,
          ),
        ),
        elevation: 0,
        backgroundColor:
            isDarkTheme ? Constants.chatGPTDarkCardColor : Colors.white,
        title: Center(
          child: Text(
            'Comments',
            style: TextStyle(color: color),
          ),
        ),
        titleSpacing: -15,
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              key: UniqueKey(),
              radius: 15,
              backgroundImage: CachedNetworkImageProvider(
                widget.postData[Constants.senderPic],
                cacheManager: MyImageCacheManager.profileCacheManager,
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatList(
                fromScreen: FromScreen.commentsScreen,
                postData: widget.postData,
              ),
            ),
            if (chatProvider.isTyping) ...[
              SpinKitDoubleBounce(
                color: color,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 10,
            ),
            BottomChatField(
              fromScreen: FromScreen.commentsScreen,
              postData: widget.postData,
            ),
          ],
        ),
      ),
    );
  }
}
