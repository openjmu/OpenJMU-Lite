///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020/2/25 10:57
///
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:badges/badges.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:openjmu_lite/constants/constants.dart';

export 'package:openjmu_lite/widgets/fixed_appbar.dart';
export 'package:openjmu_lite/widgets/no_scale_text_widget.dart';
export 'package:openjmu_lite/widgets/rounded_tab_indicator.dart';
export 'package:openjmu_lite/widgets/user_avatar.dart';
export 'package:openjmu_lite/widgets/webapp_icon.dart';
export 'package:openjmu_lite/widgets/confirmation/confirmation_bottom_sheet.dart';
export 'package:openjmu_lite/widgets/confirmation/confirmation_dialog.dart';

class TransparentRoute extends PageRoute<void> {
  TransparentRoute({
    @required this.builder,
    this.duration,
    RouteSettings settings,
  })  : assert(builder != null),
        super(settings: settings, fullscreenDialog: false);

  final WidgetBuilder builder;
  final Duration duration;

  @override
  bool get opaque => false;
  @override
  Color get barrierColor => null;
  @override
  String get barrierLabel => null;
  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => duration ?? Duration.zero;

  @override
  Widget buildPage(
      BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final result = builder(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }
}

/// Max radius for border radius.
const maxBorderRadius = BorderRadius.all(Radius.circular(999999));

/// Constant widgets.
///
/// This section was declared for widgets that will be reuse in code.
/// Including [OpenJMULogo], [DeveloperTag], [separator], [emptyDivider], [badgeIcon],
/// [PlatformProgressIndicator], [LoadMoreIndicator], [ScaledImage]

/// OpenJMU logo.
class OpenJMULogo extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const OpenJMULogo({
    Key key,
    this.width = 80.0,
    this.height,
    this.radius = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(suSetWidth(radius)),
        child: Image.asset("images/logo_1024.png", width: width, height: height),
      ),
    );
  }
}

/// Common separator. Used in setting separate.
Widget separator(context, {Color color, double height}) => DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).canvasColor,
      ),
      child: SizedBox(height: suSetHeight(height ?? 8.0)),
    );

/// Empty divider. Used in widgets need empty placeholder.
Widget emptyDivider({double width, double height}) => SizedBox(
      width: width != null ? suSetWidth(width) : null,
      height: height != null ? suSetHeight(height) : null,
    );

/// Badge Icon. Used in notification.
Widget badgeIcon({
  @required content,
  @required Widget icon,
  EdgeInsets padding,
  bool showBadge = true,
}) =>
    Badge(
      padding: padding ?? const EdgeInsets.all(5.0),
      badgeContent: Text('$content', style: TextStyle(color: Colors.white)),
      badgeColor: currentThemeColor,
      child: icon,
      elevation: Platform.isAndroid ? 2 : 0,
      showBadge: showBadge,
    );

/// SpinKit widget
class SpinKitWidget extends StatelessWidget {
  final Color color;
  final Duration duration;
  final double size;

  const SpinKitWidget({
    Key key,
    this.color,
    this.duration = const Duration(milliseconds: 1500),
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCube(
      color: color ?? currentThemeColor,
      duration: duration,
      size: suSetWidth(size),
    );
  }
}

/// Progress Indicator. Used in loading data.
class PlatformProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  final Color color;
  final double value;
  final Brightness brightness;

  const PlatformProgressIndicator({
    Key key,
    this.strokeWidth = 4.0,
    this.radius = 10.0,
    this.color,
    this.value,
    this.brightness,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoTheme(
            data: CupertinoThemeData(brightness: brightness ?? currentBrightness),
            child: CupertinoActivityIndicator(radius: radius),
          )
        : CircularProgressIndicator(
            strokeWidth: suSetWidth(strokeWidth),
            valueColor: color != null ? AlwaysStoppedAnimation<Color>(color) : null,
            value: value,
          );
  }
}

/// Load more indicator.
class LoadMoreIndicator extends StatelessWidget {
  final bool canLoadMore;

  const LoadMoreIndicator({
    Key key,
    this.canLoadMore = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: suSetHeight(50.0),
      child: canLoadMore
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SpinKitWidget(size: 24.0),
                Text(
                  '　正在加载',
                  style: TextStyle(fontSize: suSetSp(18.0)),
                ),
              ],
            )
          : Center(
              child: Text(
                Constants.endLineTag,
                style: TextStyle(fontSize: suSetSp(18.0)),
              ),
            ),
    );
  }
}

class NoSplashFactory extends InteractiveInkFeatureFactory {
  const NoSplashFactory();

  @override
  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return NoSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      onRemoved: onRemoved,
    );
  }
}

class NoSplash extends InteractiveInkFeature {
  NoSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    Color color,
    VoidCallback onRemoved,
  })  : assert(controller != null),
        assert(referenceBox != null),
        super(controller: controller, referenceBox: referenceBox, onRemoved: onRemoved) {
    controller.addInkFeature(this);
  }
  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {}
}
