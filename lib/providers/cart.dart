import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity; // quantity of the items that the user buy.
  final double
      price; // price per product. we calculate the total price by multiplying
  // with quantity.

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {}; // it must be initializes.
  // If it not initialize then containsKey or these kind of methods did'nt work.

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    // return _items == null ? 0 : // does'nt require anymore when _items initializes.
    return _items.length; // if 3 products then return 3. you
    // can also sum all quantities of products.
  }

  double get totalAmount {
    // this getter calculates the total amount for the cart.
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    // here we assume that quantity is always be 1.
    if (_items.containsKey(productId)) {
      // change quantity...
      // existing value automatically founds for that key.
      _items.update(
          productId,
          (existingCartItem) => CartItem(
                id: existingCartItem.id,
                title: existingCartItem.title,
                price: existingCartItem.price,
                quantity: existingCartItem.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
                id: DateTime.now().toString(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    // to remove item from map using key when item dissmissed on swiping.
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return; // returns cancels the function execution.
    }
    if (_items[productId].quantity > 1) {
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              quantity: existingCartItem.quantity - 1,
              price: existingCartItem.price));
    } else {
      _items.remove(productId);  // remove the entire item with the help of
      // the key which is mapped to it.
    }
    notifyListeners();
  }

  // after confirming the order the cart is cleared.
  void clear() {
    _items = {};
    notifyListeners();
  }
}

// _items are the items in the cart.
