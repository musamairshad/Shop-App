import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;
  // ProductDetailScreen(this.title);

  static const routeName = "/product-detail";

  const ProductDetailScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    // adding a product doesn't effect this screen so that's why listen: false.
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        // CustomScrollView is for more controlling.
        slivers: [
          // slivers are scrollable areas on the screen.
          SliverAppBar(
            expandedHeight: 300, // this is height the appbar have when it is image.
            pinned: true, // means the appbar is always visible when we scroll.
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              // background is the part which is visible if this is expanded.
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(loadedProduct.imageUrl, fit: BoxFit.cover)),
            ),
          ),
          SliverList(
            // SliverList is a listview as part of multiple slivers.
            // delegate property is for how to render the content of the list.
            delegate: SliverChildListDelegate([
              const SizedBox(
              height: 10,
            ),
            Text("\$${loadedProduct.price}", 
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 20,
            ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              width: double.infinity,
              child: Text(loadedProduct.description, textAlign: TextAlign.center,
              softWrap: true,
              ),
            ),
            const SizedBox(
              height: 800,
            ),
            ]),
          ), // your listview as a part of multiple slivers.
        ], // slivers are basically scrollable areas on the screen.
        // child: Column(
        //   children: [
        //     SizedBox(
        //       // we output image in a container.
        //       height: 300,
        //       width: double.infinity,
        //       child: 
        //     ),
            
        //   ],
        // ),
      ),
    );
  }
}
