import 'package:flutter/cupertino.dart';

class RouteTransitions {
  static Route<bool> createSlideTransitionRoute(Widget screen) {
    return CupertinoPageRoute<bool>(
      fullscreenDialog: false,
      builder: (BuildContext context) => screen,
    );
  }
}
