import 'package:flutter/material.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = "/edit-product";

  const EditProductScreen({Key key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>(); // In this case global key allow's us to
  // interact with a state which is behind the scenes of the forms.
  var _editedProduct = Product(
    id: null,
    title: "",
    price: 0,
    description: "",
    imageUrl: "",
    // isFavorite: null
  );

  var _initValues = {
    "title": "",
    "description": "",
    "price": "",
    "imageUrl": "",
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // this method also runs before build runs.
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _initValues = {
          "title": _editedProduct.title,
          "description": _editedProduct.description,
          "price": _editedProduct.price.toString(),
          // "imageUrl" : _editedProduct.imageUrl,
          "imageUrl": "",
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit =
        false; // so for future executions of didChangeDependencies we dont re
    // initialize the form.
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Focus nodes still stick around even when the screen is cleared so
    // it will lead to memory leaks so that's why we dispose them when state
    // object is distroyed.
    _imageUrlFocusNode.removeListener(_updateImageUrl); // so first remove the
    // listener from it and then dispose it.
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      // this block executes if we are not focusing anymore.
      if ((!_imageUrlController.text.startsWith("http") &&
              !_imageUrlController.text.startsWith("https")) ||
          (!_imageUrlController.text.endsWith(".png") &&
              !_imageUrlController.text.endsWith(".jpg") &&
              !_imageUrlController.text.endsWith(".jpeg"))) {
        return;
      }
      setState(() {});
    }
  }

  // .) To make direct a access to form inside of your widget you need a global key which
// requires in very rare conditions.

// .) You typically need a global key when you need interact with a widget from
// inside of your code.

  // void => previously saveForm is of void type.

  Future<void> _saveForm() async {
    final isValid = _form.currentState
        .validate(); // It returns true when all validators returns
    // null and return false when any of the validator returns a text.
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // This save method is provided by the state object _form which just save the content
    // of the form.
    if (_editedProduct.id != null) {
      // means this product has an id and it existed before.
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        // here we add await because showDialog returns a future and we should
        // await before we continue to finally block.
        // ignore: prefer_void_to_null
        await showDialog<Null>(
            context: context,
            builder: (ctx) {
              return AlertDialog(
                title: const Text("An error occurred!"),
                // every object in dart has a toString method.
                content: const Text("Something went wrong."),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop(); // After we pressed this button
                      // the future return by showDialog will be resolved.
                    },
                    child: const Text("Okay"),
                  ),
                ],
              );
            });
      } 
      // finally {
      //   // this block always runs no matter we succeed or fails.
      //   setState(() {
      //     _isLoading = false;
      //   });
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
        _isLoading = false;
      });
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
  }
  // .catchError((error) {
  // return
  // }).then((_) {
  // Our future resolves to void but we still have to accept argument in .then()
  // function.

  // });

  // Navigator.of(context).pop();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Product"),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _initValues["title"],
                      decoration: const InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction
                          .next, // The next option is on the bottom
                      // right of the keyboard.
                      onFieldSubmitted: (_) {
                        // you can also use _ in the place of value.
                        FocusScope.of(context).requestFocus(_priceFocusNode);
                        // after next we assign the _priceFocusNode to the second textformField.
                      }, // this will fire when
                      // next button is pressed and there you will get a
                      // value which was entered.
                      validator: (value) {
                        // return null; // there is no error means input is perfect.
                        if (value.isEmpty) {
                          return "Please provide a value.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // the value you enter in a field.
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: value,
                          description: _editedProduct.description,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["price"],
                      decoration: const InputDecoration(
                        labelText: "Price",
                      ),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context)
                            .requestFocus(_descriptionFocusNode);
                      }, // this will fire when next button is pressed.
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a price.";
                        }
                        if (double.tryParse(value) == null) {
                          // if tryparse failed to parse then it returns a null
                          // value instead of throwing an error.
                          return "Please enter a valid number.";
                        }
                        if (double.parse(value) <= 0) {
                          return "Please enter a number greater than zero.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(value),
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues["description"],
                      decoration: const InputDecoration(
                        labelText: "Description",
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
                      // textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please enter a description.";
                        }
                        if (value.length < 10) {
                          return "Should be at least 10 characters long.";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: value,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl,
                          isFavorite: _editedProduct.isFavorite,
                        );
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(top: 23, right: 15),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                          ),
                          child: _imageUrlController.text.isEmpty
                              ? const Center(child: Text("Enter a URL"))
                              : FittedBox(
                                  child: Image.network(
                                    _imageUrlController.text,
                                    fit: BoxFit.cover,
                                    // this will off course an invalid url right now.
                                  ),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            // initialValue: _initValues["imageUrl"],
                            // You can't set both the initial value and the controller
                            // at the same time.
                            // textformfield takes as much width as it can get.
                            controller: _imageUrlController,
                            decoration: const InputDecoration(
                              labelText: "Image URL",
                            ),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            focusNode: _imageUrlFocusNode,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please enter an image URL.";
                              }
                              if (!value.startsWith("http") &&
                                  !value.startsWith("https")) {
                                return "Please enter a valid URL.";
                              }
                              if (!value.endsWith(".png") &&
                                  !value.endsWith(".jpg") &&
                                  !value.endsWith(".jpeg")) {
                                return "Please enter a valid image URL.";
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) {
                              _saveForm();
                            },
                            onSaved: (value) {
                              _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: value,
                                isFavorite: _editedProduct.isFavorite,
                              );
                            },
                            onEditingComplete: () {
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
