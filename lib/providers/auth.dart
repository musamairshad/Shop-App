import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/http_exception.dart';
import '../api/api_key.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate; // expiry date of the token.
  String _usedId; // id of the auth user.
  Timer _authTimer;

  bool get isAuth {
    return token != null; // If it is true then we are authenticated.
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) // if it is null then we can't have a valid token.
    {
      return _token;
    }
    return null;
  }

  String get userId {
    // we could add if check's here.
    return _usedId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$tmdbApiKey");
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": password,
            "returnSecureToken": true,
          },
        ),
      );
      // print(json.decode(response.body));
      final responseData = json.decode(response.body);
      if (responseData["error"] != null) {
        throw HttpException(responseData["error"]["message"]);
      }
      _token = responseData["idToken"];
      _usedId = responseData["localId"];
      _expiryDate = DateTime.now().add(Duration(
        seconds: int.parse(
          responseData["expiresIn"],
        ),
      ));
      _autoLogout(); // this is where the user's officially treated as login users.
      notifyListeners();
      // shared preferences used to store key value in your device.
      // shared preferences also invloves working with future.
      final prefs = await SharedPreferences.getInstance();
      // JSON data is always ended up with string.
      final userData = json.encode({
        "token": _token,
        "userId": _usedId,
        "expiryDate": _expiryDate.toIso8601String()
      });
      // The key in setString is used for retriving the data.
      prefs.setString("userData", userData);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, "signUp");
    // the future return by the authenticate is the future that awaits and that
    // takes a bit longer.
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, "signInWithPassword");
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey("userData")) {
      // Means there is no valid token.
      return false;
    }
    // We still get some data even the token is already expired.
    final extractedUserData =
        json.decode(prefs.getString("userData")) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData["expiryDate"]);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData["token"];
    _usedId = extractedUserData["userId"];
    _expiryDate = expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _usedId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove("userData"); remove the prefs by passing the key. this approach
    // is good if you are storing multiple things in shared preferences.
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      // if we have an existing timer then we have cancel it before setting
      // a new one.
      _authTimer.cancel(); // this will clear all of your app's data from shared
      // preferences.
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    // Timer takes certain duration and after that duration the certain action
    // was performed so Timer performs as assynchronus operation.
    // logout() should be trigger when the timer expires.
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
