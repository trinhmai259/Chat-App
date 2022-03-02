import 'dart:io';

import 'package:achat/data_sources/firebase_repository.dart';
import 'package:achat/models/app_user.dart';
import 'package:achat/models/message.dart';
import 'package:achat/models/room_chat.dart';
import 'package:achat/resources/strings.dart';
import 'package:achat/resources/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

class FirebaseServices {
  final FirebaseRepository firebaseRepository = FirebaseRepository();
  Future createAccountWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    File? avatar,
    Function(AppUser)? onDone,
    Function? onError,
  }) async {
    try {
      await firebaseRepository.firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        if (value.user != null) {
          String? photoUrl;
          if (avatar != null) {
            photoUrl = await uploadFile(value.user!.uid, avatar);
          }
          final appUser = AppUser(
              uid: value.user!.uid,
              displayName: name,
              email: value.user!.email,
              photoUrl: photoUrl);
          await createUserToDatabase(appUser).then((value) => onDone!(appUser));
        }
      });
      Utils.showToast(SUCCESS_REGISTER);
    } on FirebaseAuthException catch (e) {
      onError!();
      if (e.code == 'weak-password') {
        Utils.showToast("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        Utils.showToast("The account already exists for that email.");
      } else {
        Utils.showToast(e.message ?? "");
      }
    }
  }

  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      await firebaseRepository.firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      Utils.showToast("Logged in successfully");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Utils.showToast("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        Utils.showToast("Wrong password provided for that user.");
      } else {
        Utils.showToast(e.message ?? "");
      }
    }
  }

  Future signInWithGoogle() async {
    UserCredential? user;
    try {
      GoogleSignInAccount? _signInAccount =
          await firebaseRepository.googleSignIn.signIn();
      if (_signInAccount != null) {
        GoogleSignInAuthentication _signInAuthentication =
            await _signInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: _signInAuthentication.accessToken,
            idToken: _signInAuthentication.idToken);

        user = await firebaseRepository.firebaseAuth
            .signInWithCredential(credential);

        if (user.user != null) {
          final appUser = AppUser(
              uid: user.user!.uid,
              displayName: user.user!.displayName ?? "",
              email: user.user!.email,
              photoUrl: user.user!.photoURL);
          await createUserToDatabase(appUser);
        }
      }
    } on FirebaseAuthException catch (e) {
      Utils.showToast(e.message ?? "");
    }
  }

  Future signOut() async {
    firebaseRepository.googleSignIn.signOut();
    return firebaseRepository.firebaseAuth.signOut();
  }

  Future<AppUser?> getUser(String uid) async {
    final snapshot =
        await firebaseRepository.firestore.collection("users").doc(uid).get();
    if (snapshot.exists) {
      return AppUser.fromJson(snapshot.data()!);
    }
  }

  Stream<User?> userChangeStream() async* {
    yield* firebaseRepository.firebaseAuth.userChanges();
  }

  Future createUserToDatabase(AppUser appUser) async {
    await firebaseRepository.firestore
        .collection("users")
        .doc(appUser.uid)
        .set(appUser.toJson());
  }

  Future<String?> uploadFile(String userId, File file) async {
    String fileName = Uuid().v4();
    try {
      final uploaTask = await firebaseRepository.firebaseStorage
          .ref('users/$userId/$fileName.jpg')
          .putFile(file);
      return uploaTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      Utils.showToast(e.message ?? "");
    }
  }

  Future sendMessage(
      {required RoomChat roomChat, required Message message}) async {
    await firebaseRepository.firestore
        .collection("chats")
        .doc(roomChat.id)
        .collection("messages")
        .doc(message.id)
        .set(message.toJson());
    await firebaseRepository.firestore
        .collection("chats")
        .doc(roomChat.id)
        .set(roomChat.toJson());
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamMessage(
      String idRoomChat) async* {
    yield* firebaseRepository.firestore
        .collection("chats")
        .doc(idRoomChat)
        .collection("messages")
        .orderBy("time_stamp", descending: true)
        .snapshots();
  }

  Future<String?> getIdRoomChat(String senderId, String recieverId) async {
    final snapshot =
        await firebaseRepository.firestore.collection("chats").get();
    for (var doc in snapshot.docs) {
      List<dynamic> membersId = doc.get("members_id");
      if (membersId.any((element) => element == senderId) &&
          membersId.any((element) => element == recieverId)) {
        return doc.get("id");
      }
    }
  }

  Future<String?> uploadFileMessage(String userId, File file) async {
    String fileName = Uuid().v4();
    try {
      final uploaTask = await firebaseRepository.firebaseStorage
          .ref('message/$userId/$fileName')
          .putFile(file);
      return uploaTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      Utils.showToast(e.message ?? "");
    }
  }

  Future updateMessageMedias(
      List<String> medias, String roomChatId, String messageId) async {
    await firebaseRepository.firestore
        .collection("chats")
        .doc(roomChatId)
        .collection("messages")
        .doc(messageId)
        .update({"medias": medias});
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getStreamUser(
      String uid) async* {
    yield* firebaseRepository.firestore
        .collection("users")
        .doc(uid)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getStreamRoomChat(
      String userId) async* {
    yield* firebaseRepository.firestore
        .collection("chats")
        .where("members_id", arrayContains: userId)
        .snapshots();
  }

  Future<List<AppUser>> searchUser(String uid) async {
    List<AppUser> listUser = [];
    final snapshot =
        await firebaseRepository.firestore.collection("users").get();
    for (var doc in snapshot.docs) {
      if (doc.id != uid) {
        print(doc.data());
        listUser.add(AppUser.fromJson(doc.data()));
      }
    }
    return listUser;
  }
}
