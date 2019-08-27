import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu_lite/apis/sign_api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/data_utils.dart';


class UserPage extends StatefulWidget {
    UserPage({this.args});

    final Map<String, dynamic> args;

    @override
    _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
    final ScrollController _scrollController = ScrollController();
    final UserInfo _user = UserAPI.currentUser;
    final Color themeColor = Constants.appThemeColor;
    final List<List<String>> settingsSection = [
        [
            "关于OpenJMU Lite",
            "退出登录",
        ],
    ];
    final List<List<String>> settingsIcon = [
        [
            "idols",
            "exit",
        ],
    ];

    bool showTitle = false;
    bool gettingSign = true, signing = false, signed = false;
    int signedCount = 0;
    double expandedHeight = kToolbarHeight + Constants.size(50.0);

    @override
    void initState() {
        getSignStatus();
        _scrollController.addListener(listener);
        super.initState();
    }

    @override
    void didChangeDependencies() {
        _scrollController
            ..removeListener(listener)
            ..addListener(listener)
        ;
        super.didChangeDependencies();
    }

    @override
    void dispose() {
        _scrollController?.dispose();
        super.dispose();
    }

    void listener() {
        double triggerHeight = expandedHeight;
        if (_scrollController.offset >= triggerHeight && !showTitle) {
            setState(() {
                showTitle = true;
            });
        } else if (_scrollController.offset < triggerHeight && showTitle) {
            setState(() {
                showTitle = false;
            });
        }
    }

    void getSignStatus() async {
        var _signed = (await SignAPI.getTodayStatus()).data['status'];
        var _signedCount = (await SignAPI.getSignList()).data['signdata']?.length;
        if (mounted) setState(() {
            this.gettingSign = false;
            this.signedCount = _signedCount;
            this.signed = _signed == 1 ? true : false;
        });
    }

    void requestSign() {
        if (!signed) {
            setState(() { signing = true; });
            SignAPI.requestSign().then((response) {
                setState(() {
                    signed = true;
                    signing = false;
                    signedCount++;
                });
                getSignStatus();
            }).catchError((e) {
                debugPrint(e.toString());
            });
        }
    }

    List<Widget> flexSpaceWidgets(context) => [
        Padding(
            padding: EdgeInsets.only(bottom: Constants.size(12.0)),
            child: Row(
                children: <Widget>[
                    UserAPI.getAvatarWidget(size: 80.0),
                    Constants.emptyDivider(width: 16.0),
                    Text(
                        _user.name,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: Constants.size(24.0),
                            fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                    ),
                    Expanded(child: SizedBox()),
                    InkWell(
                        onTap: signed ? () {} : requestSign,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(Constants.size(20.0)),
                            child: Container(
                                color: themeColor,
                                padding: EdgeInsets.symmetric(
                                    horizontal: Constants.size(8.0),
                                    vertical:  Constants.size(6.0),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: gettingSign ? <Widget>[
                                        Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: Constants.size(2.0),
                                            ),
                                            child: SizedBox(
                                                width: Constants.size(18.0),
                                                height: Constants.size(18.0),
                                                child: Constants.progressIndicator(
                                                    strokeWidth: 3.0,
                                                    color: Colors.white,
                                                ),
                                            ),
                                        ),
                                    ] : <Widget>[
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: Constants.size(signing ? 3.0 : 0.0),
                                                bottom: Constants.size(signing ? 3.0 : 0.0),
                                                left: Constants.size(signing ? 2.0 : 0.0),
                                                right: Constants.size(signing ? 8.0 : 4.0),
                                            ),
                                            child: signing ? SizedBox(
                                                width: Constants.size(18.0),
                                                height: Constants.size(18.0),
                                                child: Constants.progressIndicator(
                                                    strokeWidth: 3.0,
                                                    color: Colors.white,
                                                ),
                                            ) : Icon(
                                                Icons.assignment_turned_in,
                                                color: Colors.white,
                                                size: Constants.size(24.0),
                                            ),
                                        ),
                                        Text(
                                            signed ? "已签$signedCount天" : "签到",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: Constants.size(18.0),
                                                textBaseline: TextBaseline.alphabetic,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                ],
            ),
        ),
    ];

    Widget settingItem(int index, int i) {
        return GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: Constants.size(18.0),
                    vertical: Constants.size(18.0),
                ),
                child: Row(
                    children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(
                                left: Constants.size(12.0),
                                right: Constants.size(16.0),
                            ),
                            child: SvgPicture.asset(
                                "assets/icons/${settingsIcon[index][i]}-line.svg",
                                color: Theme.of(context).iconTheme.color,
                                width: Constants.size(30.0),
                                height: Constants.size(30.0),
                            ),
                        ),
                        Expanded(
                            child: Text(
                                settingsSection[index][i],
                                style: TextStyle(fontSize: Constants.size(19.0)),
                            ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(right: Constants.size(12.0)),
                            child: SvgPicture.asset(
                                "assets/icons/arrow-right.svg",
                                color: Colors.grey,
                                width: Constants.size(24.0),
                                height: Constants.size(24.0),
                            ),
                        ),
                    ],
                ),
            ),
            onTap: () { _handleItemClick(context, settingsSection[index][i]); },
        );
    }

    Widget settingSectionListView(int index) {
        return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, i) => Constants.separator(
                context,
                color: Theme.of(context).canvasColor,
                height: 1.0,
            ),
            itemCount: settingsSection[index].length,
            itemBuilder: (context, i) => settingItem(index, i),
        );
    }

    void _handleItemClick(context, String item) {
        switch (item) {
            case "关于OpenJMU Lite":
                Navigator.pushNamed(context, "/about");
                break;
            case "退出登录":
                DataUtils.logout(context);
                break;
            default:
                break;
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: NestedScrollView(
                controller: _scrollController,
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => <Widget>[
                    SliverAppBar(
                        title: showTitle ? GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTap: () {
                                _scrollController.animateTo(
                                    0.0,
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.ease,
                                );
                            },
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    UserAPI.getAvatarWidget(size: 30.0),
                                    SizedBox(width: Constants.size(8.0)),
                                    Text(
                                        _user.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: Constants.size(21.0),
                                            fontWeight: FontWeight.normal,
                                        ),
                                    ),
                                ],
                            ),
                        ) : null,
                        flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                                children: <Widget>[
                                    SizedBox(
                                        width: double.infinity,
                                        child: Image(
                                            image: UserAPI.getAvatarProvider(),
                                            fit: BoxFit.fitWidth,
                                            width: MediaQuery.of(context).size.width,
                                        ),
                                    ),
                                    BackdropFilter(
                                        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                                        child: Container(
                                            color: Color.fromARGB(120, 50, 50, 50),
                                        ),
                                    ),
                                    SafeArea(
                                        top: true,
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: Constants.size(20.0)),
                                            child: Column(
                                                children: <Widget>[
                                                    Constants.emptyDivider(height: kToolbarHeight + 4.0),
                                                    ListView.builder(
                                                        physics: NeverScrollableScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount: flexSpaceWidgets(context).length,
                                                        itemBuilder: (BuildContext context, int index) {
                                                            return flexSpaceWidgets(context)[index];
                                                        },
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ),
                                ],
                            ),
                        ),
                        expandedHeight: kToolbarHeight + expandedHeight,
                        iconTheme: Theme.of(context).iconTheme.copyWith(
                            color: Colors.white,
                        ),
                        primary: true,
                        centerTitle: true,
                        pinned: true,
                    ),
                ],
                body: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (context, index) => Constants.separator(context),
                    itemCount: settingsSection.length,
                    itemBuilder: (context, index) => settingSectionListView(index),
                ),
            ),
        );
    }
}
