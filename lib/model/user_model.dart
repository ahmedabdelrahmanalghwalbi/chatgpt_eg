import 'package:chat_gpt_eg/constants/constants.dart';

class UserModel {
  String uid;
  String name;
  String profilePic;
  String phone;
  String aboutMe;
  String lastSeen;
  String dateJoined;
  bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.phone,
    required this.aboutMe,
    required this.lastSeen,
    required this.dateJoined,
    required this.isOnline,
  });

  Map<String, dynamic> toMap() {
    return {
      Constants.uid: uid,
      Constants.name: name,
      Constants.profilePic: profilePic,
      Constants.phone: phone,
      Constants.aboutMe: aboutMe,
      Constants.lastSeen: lastSeen,
      Constants.dateJoined: dateJoined,
      Constants.isOnline: isOnline,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data[Constants.uid] ?? '',
      name: data[Constants.name] ?? '',
      profilePic: data[Constants.profilePic] ?? '',
      phone: data[Constants.phone] ?? '',
      aboutMe: data[Constants.aboutMe] ?? '',
      lastSeen: data[Constants.lastSeen] ?? '',
      dateJoined: data[Constants.dateJoined] ?? '',
      isOnline: data[Constants.isOnline] ?? false,
    );
  }
}
