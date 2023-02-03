import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/orders.dart' as ord;
import 'dart:math';

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  const OrderItem(this.order, {Key key}) : super(key: key);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(
        milliseconds: 300,
      ),
      // 10 to 110 and 100 to 200
      height: _expanded ? min(widget.order.products.length * 20.0 + 110, 200) : 95,
      child: Card(
        margin: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ListTile(
                title: Text("\$${widget.order.amount.toStringAsFixed(2)}"),
                subtitle: Text(
                  DateFormat("dd/MM/yyyy hh:mm").format(widget.order.dateTime),
                ),
                trailing: IconButton(
                    onPressed: () {
                      setState(() {
                        _expanded = !_expanded; // If it is false we set it to true
                      // or vice versa.
                      });
                    },
                    icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more)),
              ),
              // if (_expanded)  // if expanded is true then this container runs.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                    // height depends on the amount of items in the list.
                    // 10 is the base height of the container.
                    // for super big containers of infinite heights we use 100.
                    height: _expanded ? min(widget.order.products.length * 20.0 + 10, 100) : 0,
                    child: ListView(
                      children: widget.order.products.map((prod) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(prod.title, style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            ),
                          Text("${prod.quantity}x \$${prod.price}", style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
