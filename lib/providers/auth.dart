import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/models/http_exception.dart';
import 'package:provider_pattern/providers/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _apiKey = "AIzaSyBaSy0NPJ63AzVrji8aIqYx0Ilwm1acUZw";
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;
  String _email;

  UserProfile _userProfile;
  UserProfile get userProfile {
    return _userProfile;
  }

  List<UserProfile> _userProfiles = [];
  List<UserProfile> get userProfiles {
    return [..._userProfiles];
  }

  bool get isAuth {
    return token != null;
  }

  String get email {
    return _email;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  Future<void> _authenticateUser(
      String email, String password, String urlSegment) async {
    final String _signUpUrl =
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$_apiKey";
    try {
      final response = await http.post(_signUpUrl,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      // print(response.body);
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _email = email;

      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogOut();

      final sharedPrefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
        'email': email
      });

      sharedPrefs.setString('userData', userData);
      notifyListeners();
    } catch (e) {
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    final sharedPref = await SharedPreferences.getInstance();
    if (!sharedPref.containsKey('userData')) {
      return false;
    }
    final sharedData = sharedPref.getString('userData');
    final extractedUserData = json.decode(sharedData) as Map<String, Object>;
    final exipiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (exipiryDate.isBefore(DateTime.now())) return false;

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _expiryDate = exipiryDate;
    _email = extractedUserData['email'];
    notifyListeners();
    _autoLogOut();
    return true;
  }

  Future<void> signUp(String email, String password, String phone) async {
    await _authenticateUser(email, password, "signUp").then((_) {
      _addUserProfile(email, phone);
    });
  }

  Future<void> login(String email, String password) async {
    await _authenticateUser(email, password, "signInWithPassword");
  }

  Future<void> _addUserProfile(String email, String phoneNumber) async {
    try {
      final userProfile = new UserProfile(
          email: email, phoneNumber: phoneNumber, address: "", userId: userId);
      final response = await http.post(
          Constants.firebaseUrl + "/userprofiles.json?auth=$token",
          body: json.encode({
            'phoneNumber': userProfile.phoneNumber,
            'email': userProfile.email,
            'userId': userId,
            'address': ""
          }));
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final response = await http.post(
          "https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=$_apiKey",
          body: json.encode({'requestType': 'PASSWORD_RESET', 'email': email}));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
    } catch (error) {
      throw error;
    }
  }

  Future<void> getUserProfile() async {
    if (_userProfile != null) {
      return;
    }
    try {
      _userProfiles = [];
      final response = await http.get(Constants.firebaseUrl +
          '/userprofiles.json?orderBy="email"&equalTo="$email"&auth=$token');

      final responseData = json.decode(response.body);

      responseData.forEach((userProfileId, userProfile) {
        print(userProfileId + "xxxxxxxx");
        _userProfiles.add(UserProfile(
            id: userProfileId,
            address: userProfile['address'],
            email: userProfile['email'],
            phoneNumber: userProfile['phoneNumber'],
            userId: userProfile['userId']));
      });

      _userProfile = _userProfiles[0];
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateUserProfile(UserProfile userProfile) async {
    final _updatebaseUrl = Constants.firebaseUrl +
        "/userprofiles/${userProfile.id}.json?auth=$token";

    // final int userIndex =
    //  _userProfiles.indexWhere((cat) => cat.userId == userProfile.userId);
    //if (userIndex >= 0) {
    try {
      final response = await http.patch(_updatebaseUrl,
          body: json.encode({
            'phoneNumber': userProfile.phoneNumber,
            'email': userProfile.email,
            'address': userProfile.address,
            'userId': userProfile.userId
          }));
      _userProfile = new UserProfile(
          id: userProfile.id,
          userId: userProfile.userId,
          phoneNumber: userProfile.phoneNumber,
          email: userProfile.email,
          address: userProfile.address);
      notifyListeners();
    } catch (error) {
      throw (HttpException(error));

      //    }
      //    _userProfiles[userIndex] = userProfile;

      // } else {
      //   print('userProfile update for ${userProfile.userId} failed');
    }
  }

  Future<void> logout() async {
    _userId = null;
    _token = null;
    _email = null;
    _expiryDate = null;
    _userProfile = null;
    _userProfiles = [];
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
