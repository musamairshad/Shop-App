// exception is an abstract class. abstract means we can't directly instantiate this.
// impliments => We are signing a contract, we're forced to impliment all functions exception
// class has.

// every class invisibly extends object that's why every class has a toString() method.
// Object is the base class which every object is based on.

class HttpException implements Exception {
  final String message;

  HttpException(this.message);

  @override
  String toString() {
    // return super.toString(); // prints Instance of HttpException thing.
    return message;
  }
}

// Normally toString prints Instance of HttpException thing.