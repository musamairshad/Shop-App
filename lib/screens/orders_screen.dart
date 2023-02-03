import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = "/orders";

  const OrdersScreen({Key key}) : super(key: key);

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  // var _isLoading = false;
  @override
  void initState() {
    _ordersFuture = _obtainOrdersFuture();
    //   // Future.delayed gives us a new future.
    //   // Future.delayed(Duration.zero).then((_) async {
    //   // this Future.delayed() will actually run after build was called.
    //   // With listen: false you could also make that method call without Future.delayed()
    //   // too.
    //   //   _isLoading = true; // this will run before build runs.

    //   // // tunnel which is establish with the help of context.
    //   // Provider.of<Orders>(context, listen: false).fetchAndSetOrders().then((_){
    //   //   setState(() {
    //   //   _isLoading = false;
    //   // });
    //   // });

    //   // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print("building orders.");
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Your Orders"),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          // if the fetchAndSetOrders method run again then new future is obtained because
          // new request is sent to the server and we get th response of it
          // and that's not a problem here because we dont have any state changing logic
          // here but it becomes a problem in some cases.
          future:
              _ordersFuture, // So now no new future is created just because your widget
          // rebuild's and no unnecessary HTTP requests are sent!
          // builder takes the current snapshot, the current state of your future so you can
          // render different content based on your future.
          // builder takes a 2nd argument which is the data return by your futures.
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                // ...
                // Do error handling stuff here...
                return const Center(
                  child: Text("An error occurred!"),
                );
              } else {
                // the static child in Consumer never changes.
                return Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) =>
                            OrderItem(orderData.orders[i])));
              }
            }
          },
        ));
  }
}
