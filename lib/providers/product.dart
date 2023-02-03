import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite; // changeable that's why not final.

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final oldStatus = isFavorite;
    // We just have to invert the value of favourite icon.
    isFavorite = !isFavorite;
    notifyListeners(); // Its like set state. It notify listing widgets so
    // they gets rebuild.
    final url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
        '/userFavorites/$userId/$id.json', {"auth": token});
    try {
      // we dont want to append new values when we switch the status so
      // that's why change patch to put.
      // put request is for overriding the existing status.
      final response = await http.put(url,
          body: json.encode(
            isFavorite, // now we just send true or false as a value.
          //   {
          //   isFavorite,
          //   // "isFavorite": isFavorite,
          // }
          ));
      if (response.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (error) {
      _setFavValue(oldStatus);
    }
  }
}
