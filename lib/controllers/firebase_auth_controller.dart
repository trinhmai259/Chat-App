import 'dart:async';
import 'dart:io';
import 'package:achat/data_sources/firebase_services.dart';
import 'package:achat/models/app_user.dart';
import 'package:achat/resources/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

enum AuthStatus { none, authenticate, unauthenticate }

class FirebaseAuthController with ChangeNotifier {
  AuthStatus authStatus = AuthStatus.none;

  FirebaseServices _firebaseServices = FirebaseServices();
  late StreamSubscription _authStreamSubscription;

  AppUser? appUser;
  bool isLoading = false;

  FirebaseAuthController() {
    _init();
  }

  void _init() {
    _authStreamSubscription =
        _firebaseServices.userChangeStream().listen((user) async {
      if (user != null) {
        await _firebaseServices.getUser(user.uid).then((value) async {
          if (value != null) {
            appUser = value;
            authStatus = AuthStatus.authenticate;
          }
        });
      } else {
        appUser = null;
        authStatus = AuthStatus.unauthenticate;
      }
      notifyListeners();
    });
  }

  Future signInWithEmailAndPassword(
      {required String email, required String password}) async {
    _loading();
    await _firebaseServices.signInWithEmailAndPassword(
        email: email, password: password);
    _unLoading();
  }

  Future signInWithGoogle() async {
    _loading();
    await _firebaseServices.signInWithGoogle();
    _unLoading();
  }

  Future<bool> createAccount(
      {required String name,
      required String email,
      required String password,
      File? file}) async {
    bool created = false;
    _loading();
    await _firebaseServices.createAccountWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        onDone: (user) {
          appUser = user;
          authStatus = AuthStatus.authenticate;
          _unLoading();
          created = true;
        },
        onError: () {
          created = false;
        });
    return created;
  }

  Future signOut() async {
    _loading();
    await _firebaseServices.signOut();
    _unLoading();
  }

  Future<bool> updateUser(
      {required String displayName, required File? avatar}) async {
    _loading();
    try {
      await _firebaseServices.UpdateUser(
          userId: appUser!.uid!,
          displayName:
              displayName.isEmpty ? appUser!.displayName! : displayName);
      appUser = await _firebaseServices.getUser(appUser!.uid!);
      Utils.showToast("Cập thông tin người dùng thành công!");
      _unLoading();
      return true;
    } on FirebaseException catch (e) {
      _unLoading();
      Utils.showToast(e.message ?? "");
      return false;
    }
  }

  _loading() {
    isLoading = true;
    notifyListeners();
  }

  _unLoading() {
    isLoading = false;
    notifyListeners();
  }
}
