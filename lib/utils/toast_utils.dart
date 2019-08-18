import 'package:flutter/material.dart' show Colors;
import 'package:fluttertoast/fluttertoast.dart';


void showLongToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
    );
}

void showShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
    );
}

void showCenterShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
    );
}

void showCenterErrorShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        backgroundColor: Colors.redAccent,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
    );
}

void showTopShortToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
    );
}

void cancelToast() {
    Fluttertoast.cancel();
}
