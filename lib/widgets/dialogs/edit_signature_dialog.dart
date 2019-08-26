import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/apis/user_api.dart';
//import 'package:openjmu_lite/widgets/dialogs/LoadingDialog.dart';


class EditSignatureDialog extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => EditSignatureDialogState();
}

class EditSignatureDialogState extends State<EditSignatureDialog> {
    TextEditingController _textEditingController;
    bool canSave = false;

    @override
    void initState() {
        super.initState();
        _textEditingController = TextEditingController(text: UserAPI.currentUser.signature ?? "")
            ..addListener(() {
                setState(() {
                    if (_textEditingController.text != UserAPI.currentUser.signature) {
                        canSave = true;
                    } else {
                        canSave = false;
                    }
                });
            });
    }

//    void updateSignature() {
//        LoadingDialogController _loadingDialogController = LoadingDialogController();
//        showDialog<Null>(
//            context: context,
//            builder: (BuildContext context) => LoadingDialog(
//                text: "正在更新签名",
//                controller: _loadingDialogController,
//                isGlobal: false,
//            ),
//        );
//        UserAPI.setSignature(_textEditingController.text).then((response) {
//            _loadingDialogController.changeState("success", "签名更新成功");
//            UserAPI.currentUser.signature = _textEditingController.text;
////            Constants.eventBus.fire(SignatureUpdatedEvent(_textEditingController.text));
//            Future.delayed(Duration(milliseconds: 2300), () {
//                Navigator.of(context).pop(_textEditingController.text);
//            });
//        }).catchError((e) {
//            debugPrint(e.toString());
//            _loadingDialogController.changeState("failed", "签名更新失败");
//        });
//    }

    @override
    Widget build(BuildContext context) {
        return Material(
            type: MaterialType.transparency,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Center(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).canvasColor,
                                borderRadius: BorderRadius.all(Radius.circular(Constants.size(12.0))),
                            ),
                            width: MediaQuery.of(context).size.width - Constants.size(100),
                            padding: EdgeInsets.only(top: Constants.size(20.0)),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    Center(child: Text("修改签名", style: Theme.of(context).textTheme.title)),
                                    Container(
                                        padding: EdgeInsets.all(Constants.size(20.0)),
                                        child: TextField(
                                            autofocus: true,
                                            style: TextStyle(fontSize: Constants.size(16.0)),
                                            controller: _textEditingController,
                                            maxLength: 127,
                                            maxLines: null,
                                            decoration: InputDecoration(
                                                border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[700])),
                                                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[850])),
                                            ),
                                        ),
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                            CupertinoButton(
                                                child: Text("取消", style: TextStyle(
                                                    color: Theme.of(context).textTheme.body1.color,
                                                    fontSize: Constants.size(18.0),
                                                )),
                                                onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            CupertinoButton(
                                                child: Text("保存", style: TextStyle(
                                                    color: canSave
                                                            ? Constants.appThemeColor
                                                            : Theme.of(context).disabledColor,
                                                    fontSize: Constants.size(18.0),
                                                )),
                                                onPressed: () {
                                                    if (canSave) {
//                                                        updateSignature();
                                                    } else {
                                                        return null;
                                                    }
                                                },
                                            ),
                                        ],
                                    ),
                                ],
                            ),
                        ),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom ?? 0)
                ],
            ),
        );
    }
}