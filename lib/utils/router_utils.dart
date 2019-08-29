import 'package:flutter/material.dart';

// Routes Pages
import 'package:openjmu_lite/pages/about_page.dart';
import 'package:openjmu_lite/pages/login_page.dart';
import 'package:openjmu_lite/pages/main_page.dart';
import 'package:openjmu_lite/pages/scan_qrcode_page.dart';
import 'package:openjmu_lite/pages/splash_page.dart';
import 'package:openjmu_lite/pages/user_page.dart';

class RouterUtils {
    static final String pathDivider = "/";

    static Map<String, WidgetBuilder> routes = {
        "${pathDivider}splash": (BuildContext context) => SplashPage(),
        "${pathDivider}login": (BuildContext context) => LoginPage(),
        "${pathDivider}main": (BuildContext context) => MainPage(),

        "${pathDivider}user": (BuildContext context, {Map<String, dynamic> arguments}) => UserPage(),
        "${pathDivider}scanqrcode": (BuildContext context) => ScanQrCodePage(),
        "${pathDivider}about": (BuildContext context) => AboutPage(),

//        "${pathDivider}test": (BuildContext context) => (),
    };
}


class TransparentPageRoute extends PageRoute<void> {
    TransparentPageRoute({
        @required this.builder,
        RouteSettings settings,
    })  : assert(builder != null),
                super(settings: settings, fullscreenDialog: false);

    final WidgetBuilder builder;

    @override
    bool get opaque => false;
    @override
    Color get barrierColor => null;
    @override
    String get barrierLabel => null;
    @override
    bool get maintainState => true;
    @override
    Duration get transitionDuration => Duration(milliseconds: 250);

    @override
    Widget buildPage(BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
        final result = builder(context);
        return Semantics(
            scopesRoute: true,
            explicitChildNodes: true,
            child: result,
        );
    }
}

class FadePageTransitionsBuilder extends PageTransitionsBuilder {
    const FadePageTransitionsBuilder();

    @override
    Widget buildTransitions<T>(
            PageRoute<T> route,
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
            ) {
        return FadePageTransition(routeAnimation: animation, child: child);
    }
}

class FadePageTransition extends StatelessWidget {
    FadePageTransition({
        Key key,
        @required Animation<double> routeAnimation,
        @required this.child,
    }) : _opacityAnimation = routeAnimation.drive(_easeInTween),
                super(key: key);

    static final Animatable<double> _easeInTween = CurveTween(curve: Curves.easeIn);

    final Animation<double> _opacityAnimation;
    final Widget child;

    @override
    Widget build(BuildContext context) {
        return FadeTransition(
            opacity: _opacityAnimation,
            child: child,
        );
    }
}
