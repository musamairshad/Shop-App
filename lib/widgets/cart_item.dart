import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  const CartItem(this.id, this.productId, this.price, this.quantity, this.title,
      {Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      confirmDismiss: (direction) {
        // return Future.value(true);
        // this future will eventually returns a result in bool which means whether we want
        // to dismiss or not.
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text("Are you sure?"),
                  content:
                      const Text("Do you want to remove the item from the cart?"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: const Text("No"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ));
      },
      direction: DismissDirection.endToStart,
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
        // don't want to add listener here because we only cart related info from
        // provider cart.
      },
      background: Container(
        color: Theme.of(context).errorColor,
        // swip content is always behind the card.
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        margin: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 40),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: FittedBox(
                    child: Text(
                  "\$ $price",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                )),
              ),
            ),
            title: Text(title),
            subtitle: Text("Total: \$ ${(price * quantity)}"),
            trailing: Text("$quantity x"),
          ),
        ),
      ),
    );
  }
}
