import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/my_theme_provider.dart';
import '../widgets/post_widget.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({Key? key}) : super(key: key);

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkTheme = Provider.of<MyThemeProvider>(context).themeType;
    Color color = isDarkTheme ? Colors.white : Colors.black;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Center(
            child: Text(
              'Posts',
              style: TextStyle(
                  color: color),
            ),
          ),
        ),
      body: StreamBuilder<QuerySnapshot>(
        stream: context.read<ChatProvider>().getPostsStream(),
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
                'Nothing shared yet!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5),
              ),
            );
          }


          final postsSnapshot = snapshot.data!.docs;

          return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.80,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
              ),
              itemCount: postsSnapshot.length,
              itemBuilder: (context, index){
                return PostWidget(postsData: postsSnapshot[index],);
              });

        },
      ),
    );
  }
}


