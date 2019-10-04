import 'package:flutter/material.dart';

import 'package:openjmu_lite/constants/constants.dart';


class StackAppBar extends PreferredSize {
    final Widget child;
    final Size preferredSize;
    final Color color;
    final BoxDecoration decoration;

    StackAppBar({
        Key key,
        this.child,
        this.preferredSize = const Size.fromHeight(kToolbarHeight),
        this.color,
        this.decoration,
    }) : assert(
    color != null && decoration == null
            || decoration != null && color == null
            || decoration == null && color == null
    ), super(
        key: key,
        child: child,
        preferredSize: preferredSize,
    );

    @override
    Widget build(BuildContext context) {
        return Container(
            height: preferredSize.height,
            color: color,
            decoration: decoration,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                    Constants.emptyDivider(width: 60.0),
                    child ?? SizedBox(),
                    Constants.emptyDivider(width: 60.0),
                ],
            )
        );
    }
}
