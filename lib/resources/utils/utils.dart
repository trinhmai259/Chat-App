import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class Utils {
  static showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black.withOpacity(0.8),
        textColor: Colors.white,
        fontSize: 14.0);
  }

  static showPickImageModelBottomSheet(BuildContext context,
      {required Function(File) onPickImage}) {
    ImagePicker imagePicker = ImagePicker();
    return showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 120,
        color: Theme.of(context).backgroundColor,
        child: Column(
          children: [
            ListTile(
              title: Text("From camera"),
              leading: Icon(Icons.camera_alt),
              onTap: () async {
                await imagePicker
                    .pickImage(source: ImageSource.camera)
                    .then((value) {
                  if (value != null) {
                    onPickImage(File(value.path));
                  }
                });
              },
            ),
            ListTile(
              title: Text("From gallery"),
              leading: Icon(Icons.image),
              onTap: () async {
                await imagePicker
                    .pickImage(source: ImageSource.gallery)
                    .then((value) {
                  if (value != null) {
                    onPickImage(File(value.path));
                  }
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
