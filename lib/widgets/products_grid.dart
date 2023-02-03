import 'package:flutter/material.dart';
import './product_item.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;

  const ProductsGrid(this.showFavs, {Key key, }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    // here we didn't setup listen: false because here the scenerio is
    // different because we want to show products in products grid so it
    // changes over time.
    final products = showFavs ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        // value constructor is used when you don't need context property.
        value: products[index],
        child: const ProductItem(
            // products[index].id,
            // products[index].title,
            // products[index].imageUrl,
            ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        // for fixed amount of grids.
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10, // for vertical spacing b/w grids
        mainAxisSpacing: 10, // for horizontal spacing b/w grids.
        // mainAxisExtent: 10,
      ),
    );
  }
}
