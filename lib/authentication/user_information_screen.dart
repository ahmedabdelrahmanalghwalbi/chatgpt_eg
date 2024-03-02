import 'dart:io';
import 'package:chat_gpt_eg/main_screens/home_screen.dart';
import 'package:chat_gpt_eg/model/user_model.dart';
import 'package:chat_gpt_eg/providers/authentication_provider.dart';
import 'package:chat_gpt_eg/utility/utility.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class UserInformationScreen extends StatefulWidget {
  const UserInformationScreen({Key? key}) : super(key: key);

  @override
  State<UserInformationScreen> createState() => _UserInformationScreenState();
}

class _UserInformationScreenState extends State<UserInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? finalImageFile;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    phoneController.text = authProvider.phoneNumber;
  }

  final RoundedLoadingButtonController btnController =
      RoundedLoadingButtonController();

  void selectImage(bool fromCamera) async {
    finalImageFile = await pickImage(context: context, fromCamera: fromCamera);

    cropImage(finalImageFile!.path);
  }

  void popThePickImageDialog() {
    Navigator.pop(context);
  }

  void cropImage(filePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 800,
      maxWidth: 800,
    );

    popThePickImageDialog();

    if (croppedFile != null) {
      setState(() {
        finalImageFile = File(croppedFile.path);
      });
    }
  }

  void showImagePickerDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Please choose an option'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    selectImage(true);
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.camera,
                          color: Colors.purple,
                        ),
                      ),
                      Text('Camera'),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    selectImage(false);
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.image,
                          color: Colors.purple,
                        ),
                      ),
                      Text('Gallery'),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 25.0, horizontal: 35),
              child: Column(
                children: [
                  Center(
                    child: finalImageFile == null
                        ? Stack(
                            children: [
                              const CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.deepPurple,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 70,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showImagePickerDialog();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.deepPurple,
                                backgroundImage:
                                    FileImage(File(finalImageFile!.path)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple,
                                    border: Border.all(
                                        width: 2, color: Colors.white),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(35)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showImagePickerDialog();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        // textFormFields
                        myTextFormField(
                          hintText: 'Enter your name',
                          icon: Icons.account_circle,
                          textInputType: TextInputType.name,
                          maxLines: 1,
                          maxLength: 25,
                          textEditingController: nameController,
                          enabled: true,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        myTextFormField(
                          hintText: 'Enter your phone number',
                          icon: Icons.phone,
                          textInputType: TextInputType.number,
                          maxLines: 1,
                          maxLength: 10,
                          textEditingController: phoneController,
                          enabled: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: RoundedLoadingButton(
                      controller: btnController,
                      onPressed: () {
                        saveUserDataToFireStore();
                      },
                      successIcon: Icons.check,
                      successColor: Colors.green,
                      errorColor: Colors.red,
                      color: Colors.deepPurple,
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget myTextFormField({
    required String hintText,
    required IconData icon,
    required TextInputType textInputType,
    required int maxLines,
    required int maxLength,
    required TextEditingController textEditingController,
    required bool enabled,
  }) {
    return TextFormField(
      enabled: enabled,
      cursorColor: Colors.orangeAccent,
      controller: textEditingController,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: '',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.deepPurple),
          child: Icon(
            icon,
            size: 20,
            color: Colors.white,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        hintText: hintText,
        alignLabelWithHint: true,
        border: InputBorder.none,
        fillColor: Colors.purple.shade50,
        filled: true,
      ),
    );
  }

  // store user data to fireStore
  void saveUserDataToFireStore() async {
    //final authProvider = Provider.of<AuthenticationProvider>(context, listen: false);
    final authProvider = context.read<AuthenticationProvider>();
    UserModel userModel = UserModel(
      uid: authProvider.uid!,
      name: nameController.text.trim(),
      profilePic: '',
      phone: phoneController.text,
      aboutMe: '',
      lastSeen: '',
      dateJoined: '',
      isOnline: true,
    );

    if (finalImageFile != null) {
      if (nameController.text.length >= 3) {
        authProvider.saveUserDataToFireStore(
          context: context,
          userModel: userModel,
          fileImage: finalImageFile!,
          onSuccess: () async {
            // save user data locally
            await authProvider.saveUserDataToSharedPref();

            // set signed in
            await authProvider.setSignedIn();

            // go to home screen
            navigateToHomeScreen();
          },
        );
      } else {
        btnController.reset();
        showSnackBar(
            context: context, content: 'Name must be atleast 3 characters');
      }
    } else {
      btnController.reset();
      showSnackBar(context: context, content: 'Please select an image');
    }
  }

  void navigateToHomeScreen() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false);
  }
}
