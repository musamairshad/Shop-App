import 'package:flutter/material.dart';

// MaterialPageRoute is for on the fly animation with push or pushReplaced.
// T is the data that the page you are loading will resolve once it's popped off.
class CustomRoute<T> extends MaterialPageRoute<T> {
  CustomRoute({WidgetBuilder builder, RouteSettings settings})
      : super(builder: builder, settings: settings);

  // This method is a part of material page route about how the page is animated.
  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // the first route which gets load.
    if (settings.name == "/") {
      return child; // the page we are navigating to.
    }
    return FadeTransition(
      opacity:
          animation, // this animated a double and that's what opacity needs.
      child: child,
    );
  }
}

// This is for all routes and it is more generic.
class CustomPageTransitionBuilder extends PageTransitionsBuilder {
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // the first route which gets load.
    if (route.settings.name == "/") {
      return child; // the page we are navigating to.
    }
    return FadeTransition(
      opacity:
          animation, // this animated a double and that's what opacity needs.
      child: child,
    );
  }
}
