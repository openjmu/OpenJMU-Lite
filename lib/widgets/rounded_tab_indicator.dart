import 'package:flutter/material.dart';
import 'package:openjmu_lite/constants/configs.dart';
import 'package:openjmu_lite/constants/constants.dart';


class RoundedTabIndicator extends Decoration {
    @override
    _RoundedTabIndicatorPainter createBoxPainter([VoidCallback onChanged]) {
        return _RoundedTabIndicatorPainter(this, onChanged);
    }
}

class _RoundedTabIndicatorPainter extends BoxPainter {
    final double verticalOffset = 16.0;
    final double indicatorHeight = 8.0;
    final RoundedTabIndicator decoration;

    const _RoundedTabIndicatorPainter(this.decoration, VoidCallback onChanged)
            : assert(decoration != null),
                super(onChanged);

    @override
    void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
        assert(configuration != null);
        assert(configuration.size != null);

        final Rect rect = Offset(
            offset.dx + verticalOffset / 2,
            kToolbarHeight - indicatorHeight,
        ) & Size(
            configuration.size.width - verticalOffset,
            indicatorHeight,
        );

        final Paint paint = Paint();
        paint.color = Configs.appThemeColor;
        paint.style = PaintingStyle.fill;
        canvas.drawRRect(RRect.fromRectAndCorners(
            rect,
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
        ), paint);
    }

}