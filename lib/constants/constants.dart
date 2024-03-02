import 'dart:ui';

enum FromScreen {
  commentsScreen,
  aIChatScreen,
  usersChatScreen,
}

class Constants {
  const Constants._();
  static const String baseUrl = "BASEURL";
  static const String chatgptApiKey = "CHATGPTAPIKEY";
  static const String elevenLabsBaseUrl = "ELEVENLABSAPIBASEURL";
  static const String elevenLabsApiKey = "ELEVENLABSAPIBASEURLkey";
  static const String themeStatus = 'themeStatus';
  static const String registrationScreen = '/registrationScreen';
  static const String homeScreen = '/homeScreen';
  static const String userInformationScreen = '/userInformationScreen';
  static const String landingScreen = '/landingScreen';
  static const String uid = 'uid';
  static const String name = 'name';
  static const String profilePic = 'profilePic';
  static const String phone = 'phone';
  static const String lastSeen = 'lastSeen';
  static const String dateJoined = 'dateJoined';
  static const String isOnline = 'isOnline';
  static const String aboutMe = 'aboutMe';
  static const String users = 'users';
  static const String userImages = 'userImages';
  static const String userModel = 'userModel';
  static const String isSignedIn = 'isSignedIn';
  static const String chats = 'chats';
  static const String chatGPTChats = 'chatGPTChats';
  static const String message = 'message';
  static const String senderId = 'senderId';
  static const String messageTime = 'messageTime';
  static const String isText = 'isText';
  static const String chatId = 'chatId';
  static const String images = 'images';
  static const String commentId = 'commentId';
  static const String userImageKey = 'userImageKey';
  static const String generateImageKeys = 'generateImageKeys';
  static const String posts = 'posts';
  static const String senderPic = 'senderPic';
  static const String senderName = 'senderName';
  static const String postId = 'postId';
  static const String postImage = 'postImage';
  static const String postTime = 'postTime';
  static const String comments = 'comments';
  static const String likes = 'likes';
  static const Color chatGPTDarkCardColor = Color(0xFF444654);
  static const Color chatGPTDarkScaffoldColor = Color(0xFF343541);
}
