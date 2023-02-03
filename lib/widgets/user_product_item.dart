import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import '../screens/edit_product_screen.dart';

// this widget is used to make a list of product items not grid of product items.
class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem(this.id, this.title, this.imageUrl, {Key key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        // background image requires a provider that builds the image.
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        // height: 100.0,
        width: 100,
        child: Row(
          // this row takes as much width as it can get so wrap it with a SizedBox.
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.purple,
              ),
            ),
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text("Are you sure?"),
                          content: const Text(
                              "Do you want to remove the item from the cart?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                              },
                              child: const Text("No"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await Provider.of<Products>(context,
                                          listen: false)
                                      .deleteProduct(id);
                                } catch (error) {
                                  // of(context) can't be resolved because we are inside
                                  // future therefore it's not sure whether a context still
                                  // refers to the same context it did it before.
                                  // instead of refetching the context everytime we use
                                  // scaffold as a variable here.
                                  scaffold.showSnackBar(
                                    const SnackBar(
                                      content: Text("Deleting failed!",
                                      textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                                nav.pop();
                              },
                              child: const Text("Yes"),
                            ),
                          ],
                        ));
              },
              icon: Icon(Icons.delete, color: Theme.of(context).errorColor),
            ),
          ],
        ),
      ),
    );
  }
}
