import 'dart:io';

import 'package:achat/data_sources/firebase_repository.dart';
import 'package:achat/models/app_user.dart';
import 'package:achat/resources/strings.dart';
import 'package:achat/resources/utils/utils.dart';
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
}
