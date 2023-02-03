import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import './product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  // change notifier is like an inherited widget.
  // inherited widgets establish behind the scenes communication tunnels with the
  // help of context.

  List<Product> _items = [
    // this list is not final because this _items list will change over time.
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // this getter is used to fetch items from _items list.

    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    return [..._items]; // used to fetch copy of _items.
  }

// final is a run time constant and const is a compile time constant.

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) {
      return prod.id == id;
    });
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    Map<String, String> params;
    if (filterByUser) {
      params = <String, String>{
        "auth": authToken,
        "orderBy": json.encode("creatorId"),
        "equalTo": json.encode(userId)
      };
    } else {
      params = <String, String>{
        "auth": authToken,
      };
    }
    var url = Uri.https(
        'shop-app-ee31b-default-rtdb.firebaseio.com', '/products.json', params);
    try {
      final response = await http.get(url);
      final extractedData =
          json.decode(response.body) as Map<String, dynamic>; // dynamic
      // refers to Map or anything else.
      if (extractedData == null) {
        return;
      }
      url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
          '/userFavorites/$userId.json', {"auth": authToken});
      final favoriteResponse = await http.get(url);
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          // isFavorite: prodData['isFavorite'],
          // favoriteData == null means the user has never favorited anything.
          // if we did'nt have a prodId then favoriteData[prodId] = null.
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
          imageUrl: prodData['imageUrl'],
        ));
      });
      _items = loadedProducts;
      notifyListeners();
      // print(json.decode(response.body));
    } catch (error) {
      // throw error;
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    // after using async we dont need to return future as return http because
    // // the future returns automatically.
    // future resolves void in this case.
    // _items.add(value);
    final url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
        '/products.json', {"auth": authToken});
    // .then(fn) returns another future which effectively we return here by
    // returning http.
    // headers are meta data for your request's.

    // .post() and .then() returns a future so we return http by returning overall.

    // future will resolve when .then() block is done.

    // await = we want to wait for this operation to finish beofore we move on to the next
    // line.
    // try catch block approach used on any kind of synchronos code but future.
    try {
      final response = await http.post(url,
          body: json.encode({
            // we past data in the form of maps so it easily converts into json.
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            "creatorId": userId,
            // 'isFavorite': product.isFavorite, // favorite status is not a part
            // of products anymore.
          }));
      // server only know's it's own id's.
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)['name'], // it returns id.
      );
      _items.add(newProduct); // this will add item to the and of the list.
      // _items.insert(0, newProduct); add item to the start of the list.

      // return Future.value(); // returning inside an anonymos function will not work.

      notifyListeners();
      // return Future.value(); If you return here then you instantly return and
      // you return too early then!

      // error object which you want to catch.
    } catch (error) {
      // print(error);
      rethrow;
      // throw error; // this can handle the error and create a new error.
      // you can also handle error in many ways like send it to custom
      // analytic server or anything like that.
    }

// The kind of code is called assyn code it executes code whilst other code continues
// executing.
    // .then((response) {
    // once we get response from the request then the below code is executed.
    // print(json.decode(response.body));

    // this code runs when we get the response.

    // If the error is thrown then the then block is skipped.
    // }).catchError((error) {
    // print(error);
    // throw error;

    // });
  }

  // const => compile time constant value.
  // final => run time constant value.

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items
        .indexWhere((prod) => prod.id == id); // this will return the index.
    if (prodIndex >= 0) {
      // Here the item which is currently stored at that index should be overrirde with
      // a new item.
      final url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
          '/products/$id.json', {"auth": authToken});
      await http.patch(url,
          body: json.encode({
            "title": newProduct.title,
            "description": newProduct.description,
            "imageUrl": newProduct.imageUrl,
            "price": newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    // 200 and 201 => everything worked.
    // 300 => you were redirected.
    // 400 or 4xx or 500 => something went wrong.
    final url = Uri.https('shop-app-ee31b-default-rtdb.firebaseio.com',
        '/products/$id.json', {"auth": authToken});
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    // delete does'nt throw an error if we get an error status code back from server.
    // For get and request's the http package automatically throw's an error and
    // code moves into catchError block.
    // if we get a status code greater or equal to 400.
    _items.removeAt(existingProductIndex); // we remove product from list
    // but in memory it still there.
    notifyListeners();
    final response = await http.delete(url);
    // print(respose.statusCode); // 405 is printed means an error occured.
    if (response.statusCode >= 400) {
      // If the error is thrown then we gonna roll back the removal.
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product.");
    }
    existingProduct = null; // simply to clearup the reference.
  }
  // Obtimistic updating => We re-add the product if we fail and the
  // error is thrown.
}
