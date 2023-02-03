import 'package:flutter/material.dart';
import './cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount; // total amount = quantity x price.
  final List<CartItem>
      products; // find which quantity was ordered through cart.
  final DateTime dateTime; // time at which the order was placed.

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
        '/orders/$userId.json', {"auth": authToken});
    final respose = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(respose.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData["amount"],
          dateTime: DateTime.parse(
            orderData["dateTime"],
          ),
          products: (orderData["products"] as List<dynamic>).map((item) {
            return CartItem(
              id: item["id"],
              price: item["price"],
              quantity: item["quantity"],
              title: item["title"],
            );
          }).toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
    // print(json.decode(respose.body));
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
        '/orders/$userId.json', {"auth": authToken});
    // toIso8601String() => uniform string representation of dates which we can
    // later easily convert back into DateTime object.
    final timeStamp = DateTime.now();
    final response = await http.post(url,
        body: json.encode({
          "amount": total,
          "dateTime": timeStamp.toIso8601String(),
          // products is a map with a list of nested maps inside of it.
          "products": cartProducts
              .map((cartProduct) => {
                    "id": cartProduct.id,
                    "title": cartProduct.title,
                    "quantity": cartProduct.quantity,
                    "price": cartProduct.price,
                  })
              .toList(),
        }));
    // add always adds item at the end of the list.
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)["name"],
        amount: total,
        dateTime: timeStamp,
        products: cartProducts,
      ),
    );
    // you can also use _orders.add()
    notifyListeners(); // any places in the app which are listening to this order
    // or depends on it gets rebuild by calling notifyListeners().
  }
}
