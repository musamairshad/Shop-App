import 'package:flutter/material.dart';
import './screens/products_overview_screen.dart';
import 'screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './screens/orders_screen.dart';
import 'package:provider/provider.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './helpers/custom_route.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(), // we need auth info in our
          // whole app like which screen to show to the user that's why we setup
          // a provider here.
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          // you provide data in the form of objects in provider approach.

          // .) ChangeNotifierProvider cleans up your previous data automatically.
          // .) When you create new instance of object and you want to provide
          // this, use the create approch.

          // .) But if you want to use existing object in a provider that's
          // inside a grid or list so use provider with .value().
          // create: (ctx) => Products(), // it returns a new instance of a provided class.
          // In version 3.0.0 of the provider package its builder instead of create.
          create: (ctx) => Products(null, null, []),
          update: (ctx, auth, previousProducts) => Products(
            auth.token,
            auth.userId,
            previousProducts == null ? [] : previousProducts.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(null, null, []),
          update: (ctx, auth, previousOrders) => Orders(auth.token, auth.userId,
              previousOrders == null ? [] : previousOrders.orders),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "MyShop",
          theme: ThemeData(
            fontFamily: "Lato",
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
                pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android : CustomPageTransitionBuilder(),
                    TargetPlatform.iOS : CustomPageTransitionBuilder(),
                  },
                ),
          ),
          // home screen always checks when you are navigating.
          home: auth.isAuth
              ? const ProductsOverviewScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const SplashScreen()
                          : const AuthScreen(),
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => const ProductDetailScreen(),
            CartScreen.routeName: (ctx) => const CartScreen(),
            OrdersScreen.routeName: (ctx) => const OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => const UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => const EditProductScreen(),
          },
        ),
      ),
    );
  }
}
