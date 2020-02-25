///
/// [Author] Alex (https://github.com/AlexVincent525)
/// [Date] 2020-01-22 14:47
///
import 'package:flutter/material.dart';

import 'package:openjmu_lite/constants/constants.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    Key key,
    this.title,
    this.centerTitle = true,
    this.child,
    this.content,
    this.contentPadding,
    this.contentAlignment = TextAlign.center,
    this.backgroundColor = Colors.transparent,
    this.showConfirm = false,
    this.confirmLabel = '确认',
    this.cancelLabel = '取消',
    this.onConfirm,
    this.onCancel,
  })  : assert(
          !(child == null && content == null) && !(child != null && content != null),
          '\'child\' and \'content\' cannot be set or not set at the same time.',
        ),
        super(key: key);

  final String title;
  final bool centerTitle;
  final Widget child;
  final String content;
  final EdgeInsetsGeometry contentPadding;
  final TextAlign contentAlignment;
  final Color backgroundColor;
  final bool showConfirm;
  final String confirmLabel;
  final String cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static Future<bool> show(
    BuildContext context, {
    String title,
    bool centerTitle = true,
    Widget child,
    String content,
    EdgeInsetsGeometry contentPadding,
    TextAlign contentAlignment = TextAlign.center,
    bool showConfirm = false,
    String confirmLabel = '确认',
    String cancelLabel = '取消',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => ConfirmationDialog(
            title: title,
            centerTitle: centerTitle,
            child: child,
            content: content,
            contentPadding: contentPadding,
            contentAlignment: contentAlignment,
            showConfirm: showConfirm,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
          ),
        ) ??
        false;
  }

  Widget titleWidget(BuildContext context) => Row(
        mainAxisAlignment: centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: suSetSp(26.0), fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.fade,
          ),
        ],
      );

  Widget confirmButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: MaterialButton(
        elevation: 0.0,
        highlightElevation: 2.0,
        height: suSetHeight(60.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
        ),
        color: Theme.of(context).canvasColor,
        onPressed: () {
          if (onConfirm != null) {
            onConfirm();
          } else {
            Navigator.of(context).pop(true);
          }
        },
        child: Text(
          confirmLabel,
          style: TextStyle(fontSize: suSetSp(22.0)),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget cancelButton(BuildContext context) {
    return Expanded(
      flex: 5,
      child: MaterialButton(
        elevation: 0.0,
        highlightElevation: 2.0,
        height: suSetHeight(60.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(suSetWidth(10.0)),
        ),
        color: currentThemeColor.withOpacity(0.8),
        onPressed: () {
          if (onCancel != null) {
            onCancel();
          } else {
            Navigator.of(context).pop(false);
          }
        },
        child: Text(
          cancelLabel,
          style: TextStyle(
            color: Colors.white,
            fontSize: suSetSp(22.0),
            fontWeight: FontWeight.bold,
          ),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? Colors.transparent,
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(false);
          return false;
        },
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              minWidth: Screens.width / 5,
              maxWidth: Screens.width / 1.25,
              maxHeight: Screens.height / 1.5,
            ),
            padding: EdgeInsets.all(suSetWidth(30.0)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(suSetWidth(24.0)),
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (title != null) titleWidget(context),
                if (child != null)
                  child
                else
                  Padding(
                    padding: contentPadding ?? EdgeInsets.symmetric(vertical: suSetHeight(20.0)),
                    child: Text(
                      '$content',
                      style: TextStyle(fontSize: suSetSp(20.0), fontWeight: FontWeight.normal),
                      textAlign: contentAlignment,
                    ),
                  ),
                Row(
                  children: <Widget>[
                    if (showConfirm) confirmButton(context),
                    if (showConfirm) const Spacer(flex: 1),
                    cancelButton(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
