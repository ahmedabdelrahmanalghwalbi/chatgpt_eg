import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:chat_gpt_eg/model/user_model.dart';
import 'package:chat_gpt_eg/service/api_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import '../constants/constants.dart';

class ChatProvider extends ChangeNotifier {
  bool _isTyping = false;
  bool _isText = true;
  bool _isListening = false;
  bool _shouldSpeak = false;
  final bool _isLiked = false;

  bool get isTyping => _isTyping;
  bool get isText => _isText;
  bool get isListening => _isListening;
  bool get shouldSpeak => _shouldSpeak;
  bool get isLiked => _isLiked;

  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  TextToSpeech textToSpeech = TextToSpeech();
  AudioPlayer audioPlayer = AudioPlayer();

  // set the text or image
  void setIsText({required bool textMode}) {
    _isText = textMode;
    notifyListeners();
  }

  // set speech
  void setShouldSpeak({required bool speak}) {
    debugPrint('SHOULD SPEAK : $speak');
    _shouldSpeak = speak;
    notifyListeners();
  }

  void setIsListening({required bool listening}) {
    _isListening = listening;
    notifyListeners();
  }

  // chat stream
  Stream<QuerySnapshot<Object?>> getChatStream({required String uid}) {
    final Stream<QuerySnapshot> chatStream = firebaseFirestore
        .collection(Constants.chats)
        .doc(uid)
        .collection(Constants.chatGPTChats)
        .orderBy(Constants.messageTime)
        .snapshots();

    return chatStream;
  }

  // comment stream
  Stream<QuerySnapshot<Object?>> getCommentsStream({required String postId}) {
    final Stream<QuerySnapshot> commentsStream = firebaseFirestore
        .collection(Constants.posts)
        .doc(postId)
        .collection(Constants.comments)
        .orderBy(Constants.messageTime)
        .snapshots();

    return commentsStream;
  }

  // likes stream
  Stream<QuerySnapshot<Object?>> getLikesStream({required String postId}) {
    final Stream<QuerySnapshot> likesStream = firebaseFirestore
        .collection(Constants.posts)
        .doc(postId)
        .collection(Constants.likes)
        .snapshots();

    return likesStream;
  }

  // posts stream
  Stream<QuerySnapshot<Object?>> getPostsStream() {
    final Stream<QuerySnapshot> postsStream = firebaseFirestore
        .collection(Constants.posts)
        .orderBy(Constants.postTime)
        .snapshots();

    return postsStream;
  }

  Future<void> setLike({
    required UserModel userModel,
    required postData,
    required bool isLiked,
  }) async {
    try {
      _isTyping = true;
      notifyListeners();

      if (isLiked) {
        await firebaseFirestore
            .collection(Constants.posts)
            .doc(postData[Constants.postId])
            .collection(Constants.likes)
            .doc(userModel.uid)
            .delete();

        await firebaseFirestore.runTransaction((transaction) async {
          DocumentReference documentReference = firebaseFirestore
              .collection(Constants.posts)
              .doc(postData[Constants.postId]);

          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (snapshot[Constants.likes] != 0) {
            transaction.update(documentReference,
                {Constants.likes: snapshot[Constants.likes] - 1});
          }
        });
      } else {
        await firebaseFirestore
            .collection(Constants.posts)
            .doc(postData[Constants.postId])
            .collection(Constants.likes)
            .doc(userModel.uid)
            .set({
          Constants.senderId: userModel.uid,
          Constants.senderPic: userModel.profilePic,
          Constants.senderName: userModel.name,
          Constants.messageTime: FieldValue.serverTimestamp(),
        });

        await firebaseFirestore
            .collection(Constants.posts)
            .doc(postData[Constants.postId])
            .update({Constants.likes: FieldValue.increment(1)});
      }

      _isTyping = false;
      notifyListeners();
    } on FirebaseException catch (e) {
      _isTyping = false;
      notifyListeners();
      debugPrint('Error : ${e.toString()}');
    }
  }

  // send message
  Future<void> sendMessage({
    required String uid,
    required String message,
    required String modelId,
    required Function onSuccess,
    required Function onCompleted,
  }) async {
    try {
      _isTyping = true;
      notifyListeners();

      // send user message to fireStore
      await sendMessageToFireStore(uid: uid, message: message);

      // send the same message to chatGPT and get answer
      await sendMessageToChatGPT(
          uid: uid, message: message, isText: isText, modelId: modelId);

      _isTyping = false;
      onSuccess();
    } catch (error) {
      _isTyping = false;
      notifyListeners();
      debugPrint(error.toString());
    } finally {
      _isTyping = false;
      notifyListeners();
      onCompleted();
    }
  }

  // send comment
  Future<void> sendComment({
    required UserModel userModel,
    required String message,
    required dynamic postData,
    required Function onSuccess,
  }) async {
    try {
      _isTyping = true;
      notifyListeners();

      String commentId = const Uuid().v4();

      // send a comment
      await firebaseFirestore
          .collection(Constants.posts)
          .doc(postData[Constants.postId])
          .collection(Constants.comments)
          .doc(commentId)
          .set({
        Constants.senderId: userModel.uid,
        Constants.senderPic: userModel.profilePic,
        Constants.senderName: userModel.name,
        Constants.commentId: commentId,
        Constants.message: message,
        Constants.messageTime: FieldValue.serverTimestamp(),
      });

      await firebaseFirestore
          .collection(Constants.posts)
          .doc(postData[Constants.postId])
          .update({Constants.comments: FieldValue.increment(1)});

      _isTyping = false;
      notifyListeners();
      onSuccess();
    } catch (error) {
      _isTyping = false;
      notifyListeners();
      debugPrint(error.toString());
    }
  }

  Future<void> sendMessageToFireStore({
    required String uid,
    required String message,
  }) async {
    String chatId = const Uuid().v4();
    await firebaseFirestore
        .collection(Constants.chats)
        .doc(uid)
        .collection(Constants.chatGPTChats)
        .doc(chatId)
        .set({
      Constants.senderId: uid,
      Constants.chatId: chatId,
      Constants.message: message,
      Constants.messageTime: FieldValue.serverTimestamp(),
      Constants.isText: isText,
    });
  }

  Future<void> sendMessageToChatGPT({
    required String uid,
    required String message,
    required bool isText,
    required String modelId,
  }) async {
    String chatId = const Uuid().v4();

    String answer = await ApiService.sendMessageToChatGPT(
        message: message, modelId: modelId, isText: isText);

    if (isText) {
      if (shouldSpeak) {
        //textToSpeech.speak(answer);
        var convertedAudio = await ApiService.fetchAudioBytes(
          text: answer,
          voiceId: '21m00Tcm4TlvDq8ikWAM',
        );

        // play our converted audio
        await playAudioText(audioBytes: convertedAudio);
      }

      await firebaseFirestore
          .collection(Constants.chats)
          .doc(uid)
          .collection(Constants.chatGPTChats)
          .doc(chatId)
          .set({
        Constants.senderId: 'assistant',
        Constants.chatId: chatId,
        Constants.message: answer,
        Constants.messageTime: FieldValue.serverTimestamp(),
        Constants.isText: isText,
      });
    } else {
      String imageUrl = await saveImageFileToFireStore(url: answer);

      await firebaseFirestore
          .collection(Constants.chats)
          .doc(uid)
          .collection(Constants.chatGPTChats)
          .doc(chatId)
          .set({
        Constants.senderId: 'assistant',
        Constants.chatId: chatId,
        Constants.message: imageUrl,
        Constants.messageTime: FieldValue.serverTimestamp(),
        Constants.isText: isText,
      });
    }
  }

  Future<void> playAudioText({required Uint8List audioBytes}) async {
    await audioPlayer.play(BytesSource(audioBytes));
  }

  Future<String> saveImageFileToFireStore({required String url}) async {
    final response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/image.jpg');
    await file.writeAsBytes(bytes);

    File compressedFile =
        await compressAndGetFile(file, '${directory.path}/image2.jpg');

    String imageName = generateImageName();

    String downloadUrl = await storeFileImageToStorage(
        '${Constants.images}/$imageName', compressedFile);

    return downloadUrl;
  }

  Future<String> storeFileImageToStorage(String ref, File file) async {
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // generate a image name
  String generateImageName() {
    final random = Random();
    final randomNumber = random.nextInt(10000);
    final imageName = 'image_$randomNumber.jpg';
    return imageName;
  }

  Future<File> compressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 90,
    );

    return result!;
  }

  Future<void> shareImage({
    required UserModel userModel,
    required dynamic imageData,
    required Function onSuccess,
  }) async {
    try {
      _isTyping = true;
      notifyListeners();

      // post image to public
      await firebaseFirestore
          .collection(Constants.posts)
          .doc(imageData[Constants.chatId])
          .set({
        Constants.senderId: userModel.uid,
        Constants.senderPic: userModel.profilePic,
        Constants.senderName: userModel.name,
        Constants.postId: imageData[Constants.chatId],
        Constants.postImage: imageData[Constants.message],
        Constants.postTime: FieldValue.serverTimestamp(),
        Constants.comments: 0,
        Constants.likes: 0,
      });

      onSuccess();
      _isTyping = false;
      notifyListeners();
    } on FirebaseFirestore catch (e) {
      _isTyping = false;
      notifyListeners();
      debugPrint('error : ${e.toString()}');
    }
  }

  // double getFileSize(File file){
  //   int sizeBytes = file.lengthSync();
  //   double sizeInMB = sizeBytes / (1024 * 1024);
  //   return sizeInMB;
  // }
}
