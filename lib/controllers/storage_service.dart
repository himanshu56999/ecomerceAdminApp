import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // To upload image to Firebase Storage
  Future<String?> uploadImage(String path, BuildContext context) async {
    // Show uploading snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Uploading image...")));
    print("Uploading image...");

    File file = File(path);

    // Check if the file exists
    if (!await file.exists()) {
      print("File does not exist at path: $path");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File not found!")));
      return null;
    }

    try {
      // Create a unique file name using a timestamp and a UUID (optional)
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a reference to Firebase Storage
      Reference ref = _storage.ref().child("shop_images/$fileName");

      // Upload the file
      UploadTask uploadTask = ref.putFile(file);

      // Wait for the upload to complete
      await uploadTask;

      // Get the download URL
      String downloadURL = await ref.getDownloadURL();
      print("Download URL: $downloadURL");

      // Optionally, show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image uploaded successfully!")));

      return downloadURL;
    } catch (e) {
      print("There was an error during the upload");
      print(e);

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to upload image")));
      return null;
    }
  }
}
