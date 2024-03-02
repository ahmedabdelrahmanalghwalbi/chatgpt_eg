import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_gpt_eg/constants/constants.dart';
import 'package:chat_gpt_eg/service/image_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/my_theme_provider.dart';
import '../widgets/post_widget.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({Key? key, required this.postData}) : super(key: key);

  final dynamic postData;

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
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
            'Post details',
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
      body: Column(
        children: [
          CachedNetworkImage(
            imageUrl: widget.postData[Constants.postImage],
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Center(
              child: Icon(
                Icons.error,
                color: Colors.red,
              ),
            ),
            cacheManager: MyImageCacheManager.generatedImageCacheManager,
          ),
          const SizedBox(
            height: 10,
          ),
          BuildLikeAndComment(
            postsData: widget.postData,
          ),
        ],
      ),
    );
  }
}
