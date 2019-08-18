import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/toast_utils.dart';


class WebPage extends StatefulWidget {
    final String url;
    final String title;
    final bool withCookie;
    final bool withAppBar;
    final bool withAction;

    WebPage({
        Key key,
        @required this.url,
        @required this.title,
        this.withCookie,
        this.withAppBar,
        this.withAction,
    }) : super(key: key);

    @override
    State<StatefulWidget> createState() => WebPageState();

    static void jump(BuildContext context, String url, String title, {bool withCookie}) {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
            return WebPage(url: url, title: title, withCookie: withCookie);
        }));
    }
}

class WebPageState extends State<WebPage> {
    final flutterWebViewPlugin = FlutterWebviewPlugin();

    bool isLoading = true;
    String _url, _title;
    Color currentThemeColor = Constants.appThemeColor;
    double currentProgress = 0.0;

    @override
    void initState() {
        super.initState();
        _url = widget.url;
        _title = widget.title;
        flutterWebViewPlugin.onStateChanged.listen((state) async {
            if (state.type == WebViewState.finishLoad) {
                String script = 'window.document.title';
                String title = await flutterWebViewPlugin.evalJavascript(script);
                if (this.mounted) setState(() {
                    if (Platform.isAndroid) {
                        this._title = title.substring(1, title.length-1);
                    } else {
                        this._title = title;
                    }
                });
                Future.delayed(const Duration(milliseconds: 500), () {
                    if (this.mounted) {
                        setState(() {
                            isLoading = false;
                            currentProgress = 0.0;
                        });
                    }
                });
            } else if (state.type == WebViewState.startLoad) {
                if (this.mounted) setState(() {
                    isLoading = true;
                });
            }
        });
        flutterWebViewPlugin.onProgressChanged.listen((progress) {
            if (this.mounted) setState(() {
                currentProgress = progress;
            });
        });
        flutterWebViewPlugin.onUrlChanged.listen((url) {
            if (this.mounted) setState(() {
                _url = url;
                Future.delayed(const Duration(milliseconds: 500), () {
                    if (this.mounted) setState(() {
                        isLoading = false;
                    });
                });
            });
        });
    }

    @override
    void dispose() {
        super.dispose();
        flutterWebViewPlugin?.hide();
        flutterWebViewPlugin?.close();
        flutterWebViewPlugin?.dispose();
    }

    Future<Null> _launchURL() async {
        if (await canLaunch(_url)) {
            await launch(_url);
        } else {
            showCenterErrorShortToast('无法打开$_url');
        }
    }

    Widget refreshIndicator() => Center(
        child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
                width: 24.0,
                height: 24.0,
                child: Constants.progressIndicator(
                    color: Colors.white,
                    strokeWidth: 3.0,
                ),
            ),
        ),
    );

    Future<bool> waitForClose() async {
        await flutterWebViewPlugin.close();
        return true;
    }

    PreferredSize progressBar(context) => PreferredSize(
        child: Container(
            color: currentThemeColor,
            height: 2.0,
            child: LinearProgressIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                value: currentProgress,
                valueColor: AlwaysStoppedAnimation<Color>(currentThemeColor),
            ),
        ),
        preferredSize: null,
    );

    @override
    Widget build(BuildContext context) {
        bool _clear;
        if (widget.withCookie != null && !widget.withCookie) {
            _clear = true;
        } else {
            _clear = false;
        }
        return WillPopScope(
            onWillPop: waitForClose,
            child: WebviewScaffold(
                clearCache: _clear,
                clearCookies: _clear,
                url: widget.url,
                allowFileURLs: true,
                appBar: !(widget.withAppBar ?? false) ? AppBar(
                    leading: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: Navigator.of(context).pop,
                    ),
                    title: Container(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                Text(
                                    _title,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                    ),
                                    overflow: TextOverflow.fade,
                                ),
                                GestureDetector(
                                    onLongPress: () {
                                        _launchURL();
                                    },
                                    onDoubleTap: () {
                                        Clipboard.setData(ClipboardData(text: _url));
                                        showShortToast("已复制网址到剪贴板");
                                    },
                                    child: Text(
                                        _url,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                        ),
                                        overflow: TextOverflow.fade,
                                    ),
                                ),
                            ],
                        ),
                    ),
                    centerTitle: true,
                    actions: <Widget>[
                        isLoading ? refreshIndicator() : SizedBox(width: 56.0),
                    ],
                    bottom: progressBar(context),
                ) : null,
                initialChild: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    color: Theme.of(context).canvasColor,
                    child: isLoading
                            ? Center(child: Constants.progressIndicator())
                            : Container(),
                ),
                persistentFooterButtons: !(widget.withAction ?? false) ? <Widget>[
                    Container(
                        margin: EdgeInsets.zero,
                        padding: EdgeInsets.zero,
                        width: MediaQuery.of(context).size.width - 16,
                        height: 24.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        Icons.keyboard_arrow_left,
                                        color: currentThemeColor,
                                        size: 24.0,
                                    ),
                                    onPressed: flutterWebViewPlugin.goBack,
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: currentThemeColor,
                                        size: 24.0,
                                    ),
                                    onPressed: flutterWebViewPlugin.goForward,
                                ),
                                IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: Icon(
                                        Icons.refresh,
                                        color: currentThemeColor,
                                        size: 24.0,
                                    ),
                                    onPressed: flutterWebViewPlugin.reload,
                                ),
                            ],
                        ),
                    ),
                ] : null,
                enableAppScheme: true,
                withJavascript: true,
                withLocalStorage: true,
                resizeToAvoidBottomInset: true,
            ),
        );
    }
}
