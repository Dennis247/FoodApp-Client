import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider_pattern/helpers/constants.dart';
import 'package:provider_pattern/models/http_exception.dart';

class UserProfileProvider with ChangeNotifier {
  final String authToken;
  final String userId;

  List<UserProfile> _userProfiles = [];
  List<UserProfile> get userProfiles {
    return [..._userProfiles];
  }

  UserProfileProvider(this._userProfiles, {this.authToken, this.userId});

  Future<void> getUserProfiles() async {
    List<UserProfile> loadedProfiles = [];

    try {
      final response = await http
          .get(Constants.firebaseUrl + "/userprofiles.json?auth=$authToken");
      final extractedUserProfiles =
          json.decode(response.body) as Map<String, dynamic>;
      if (extractedUserProfiles != null) {
        extractedUserProfiles.forEach((userProfileId, userProfile) {
          loadedProfiles.add(UserProfile(
              id: json.decode(response.body)['name'],
              userId: userProfile['userId'],
              phoneNumber: userProfile['phoneNumber'],
              email: userProfile['email'],
              address: userProfile['address']));
        });
      }
      _userProfiles = loadedProfiles.toList();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteUser(String userProfileId, String authToken) async {
    final url = Constants.firebaseUrl +
        "/userprofiles/$userProfileId.json?auth=$authToken";

    UserProfile existingUserprofile;
    int existingUserProfileIndex =
        _userProfiles.indexWhere((up) => up.userId == userProfileId);
    if (existingUserProfileIndex >= 0) {
      existingUserprofile = _userProfiles[existingUserProfileIndex];
      _userProfiles.removeAt(existingUserProfileIndex);
      notifyListeners();

      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        _userProfiles.insert(existingUserProfileIndex, existingUserprofile);
        notifyListeners();
        throw HttpException('user could not be deleted');
      } else {
        existingUserprofile = null;
      }
    }
  }
}

class UserProfile {
  final String id;
  final String userId;
  final String phoneNumber;
  final String email;
  final String address;

  UserProfile(
      {@required this.id,
      @required this.userId,
      @required this.phoneNumber,
      @required this.email,
      @required this.address});
}
