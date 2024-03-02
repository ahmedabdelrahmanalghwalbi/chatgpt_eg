import 'dart:io';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/my_theme_provider.dart';

void showSnackBar({required BuildContext context, required String content}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        content,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );
}

Future<File?> pickImage(
    {required BuildContext context, required bool fromCamera}) async {
  File? fileImage;
  if (fromCamera) {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedImage != null) {
        fileImage = File(pickedImage.path);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  } else {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedImage != null) {
        fileImage = File(pickedImage.path);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context: context, content: e.toString());
      }
    }
  }

  return fileImage;
}

Widget buildButton({
  required BuildContext context,
  required String value,
  required String text,
}) {
  final themeStatus = Provider.of<MyThemeProvider>(context);
  Color color = themeStatus.themeType ? Colors.white : Colors.black;
  return MaterialButton(
    onPressed: () {},
    padding: const EdgeInsets.symmetric(vertical: 4),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 20, color: color),
        ),
        const SizedBox(
          height: 2,
        ),
        Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: color),
        ),
      ],
    ),
  );
}
