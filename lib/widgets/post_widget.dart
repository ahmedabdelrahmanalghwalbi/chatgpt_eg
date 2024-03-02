import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_gpt_eg/main_screens/comments_screen.dart';
import 'package:chat_gpt_eg/main_screens/post_details_screen.dart';
import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:chat_gpt_eg/providers/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../providers/my_theme_provider.dart';
import '../service/image_cache_manager.dart';

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.postsData,
  });

  final dynamic postsData;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkTheme ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PostDetailsScreen(postData: postsData),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: CachedNetworkImage(
                    imageUrl: postsData[Constants.postImage],
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                    )),
                    errorWidget: (context, url, error) => const Center(
                      child: Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                    cacheManager:
                        MyImageCacheManager.generatedImageCacheManager,
                  ),
                ),
              ),
            ),
            BuildLikeAndComment(postsData: postsData)
          ],
        ),
      ),
    );
  }
}

class BuildLikeAndComment extends StatelessWidget {
  const BuildLikeAndComment({
    super.key,
    required this.postsData,
  });

  final dynamic postsData;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
    var numberOfComments = postsData[Constants.comments].toString();

    return Row(
      children: <Widget>[
        Expanded(
          child: BuildLikes(postData: postsData),
        ),
        Expanded(
          child: MaterialButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentsScreen(postData: postsData),
                ),
              );
            },
            padding: const EdgeInsets.symmetric(vertical: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  numberOfComments == '0' ? '' : numberOfComments,
                  style: TextStyle(color: color),
                ),
                const SizedBox(
                  width: 2,
                ),
                Icon(Icons.comment, color: color),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class BuildLikes extends StatefulWidget {
  const BuildLikes({
    super.key,
    required this.postData,
  });

  final dynamic postData;

  @override
  State<BuildLikes> createState() => _BuildLikesState();
}

class _BuildLikesState extends State<BuildLikes> {
  bool isLiked = false;
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
    final userModel = context.read<AuthenticationProvider>().userModel;
    return StreamBuilder<QuerySnapshot>(
      stream: context
          .read<ChatProvider>()
          .getLikesStream(postId: widget.postData[Constants.postId]),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('!'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Text(''),
          );
        }

        if (snapshot.data!.docs.isEmpty) {
          return MaterialButton(
            onPressed: () {
              context.read<ChatProvider>().setLike(
                    userModel: userModel,
                    postData: widget.postData,
                    isLiked: false,
                  );
            },
            padding: const EdgeInsets.symmetric(vertical: 4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '',
                  style: TextStyle(color: color),
                ),
                const SizedBox(
                  width: 2,
                ),
                const Icon(Icons.favorite_outline, color: Colors.red),
              ],
            ),
          );
        }

        List<String> ids = [];

        final likesSnapshot = snapshot.data!.docs;

        if (snapshot.data!.docs.isNotEmpty) {
          for (var doc in likesSnapshot) {
            ids.add(doc.id);
          }
        }

        if (ids.contains(userModel.uid)) {
          isLiked = true;
        } else {
          isLiked = false;
        }

        return MaterialButton(
          onPressed: () {
            if (isLiked) {
              context.read<ChatProvider>().setLike(
                    userModel: userModel,
                    postData: widget.postData,
                    isLiked: true,
                  );
            } else {
              context.read<ChatProvider>().setLike(
                    userModel: userModel,
                    postData: widget.postData,
                    isLiked: false,
                  );
            }
          },
          padding: const EdgeInsets.symmetric(vertical: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                likesSnapshot.length.toString(),
                style: TextStyle(color: color),
              ),
              const SizedBox(
                width: 2,
              ),
              Icon(isLiked ? Icons.favorite : Icons.favorite_outline,
                  color: Colors.red),
            ],
          ),
        );
      },
    );
  }
}
