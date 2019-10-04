import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:openjmu_lite/apis/sign_api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/constants/configs.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/constants/themes.dart';
import 'package:openjmu_lite/utils/data_utils.dart';
import 'package:openjmu_lite/utils/theme_utils.dart';


class UserPage extends StatefulWidget {
    @override
    _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
    final UserInfo _user = UserAPI.currentUser;
    final Color themeColor = Configs.appThemeColor;

    final List<List<List<String>>> settingsSection = [
        [
            ["深色主题背景", "减轻眩光，提升夜间使用体验"],
            ["切换账户", "更换账号登录APP"],
        ],
    ];

    List<Widget> settingsWidget;

    bool gettingSign = true, signing = false, signed = false;
    int signedCount = 0;

    @override
    void initState() {
        getSignStatus();
        super.initState();
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
                signed = true;
                signing = false;
                signedCount++;
                if (mounted) setState(() {});
                getSignStatus();
            }).catchError((e) {
                debugPrint(e.toString());
            });
        }
    }

    Widget signButton(context) {
        return Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 6.0,
            ),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.size(20.0)),
                color: themeColor,
            ),
            child: InkWell(
                onTap: signed ? () {} : requestSign,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        if (gettingSign) Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                            ),
                            child: SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: Constants.progressIndicator(
                                    strokeWidth: 3.0,
                                    color: Colors.white,
                                ),
                            ),
                        ),
                        if (!gettingSign && signing) Padding(
                            padding: EdgeInsets.only(
                                top: Constants.size(signing ? 3.0 : 0.0),
                                bottom: Constants.size(signing ? 3.0 : 0.0),
                                left: Constants.size(signing ? 2.0 : 0.0),
                                right: Constants.size(signing ? 8.0 : 4.0),
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
                        if (!gettingSign) Text(
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
        );
    }

    Widget settingItem(int index, int i) {
        settingsWidget = [
            Switch(value: Themes.isDark, onChanged: (bool value) {
                ThemeUtils.setDark(value);
            }),
            SizedBox(),
        ];
        return InkWell(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 18.0,
                ),
                child: Row(
                    children: <Widget>[
                        Expanded(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                    Text(
                                        settingsSection[index][i][0],
                                        style: TextStyle(fontSize: Constants.size(19.0)),
                                    ),
                                    Text(
                                        settingsSection[index][i][1],
                                        style: Theme.of(context).textTheme.caption,
                                    )
                                ],
                            ),
                        ),
                        settingsWidget[i],
                    ],
                ),
            ),
            onTap: () { _handleItemClick(context, settingsSection[index][i][0]); },
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
            case "深色主题背景":
                ThemeUtils.setDark(!Themes.isDark);
                break;
            case "切换账户":
                DataUtils.logout(context);
                break;
            case "测试":
                Navigator.pushNamed(context, "/notification");
                break;
            default:
                break;
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                actions: <Widget>[
                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                            signButton(context),
                        ],
                    ),
                ],
            ),
            body: ListView(
                children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0,
                            vertical: 18.0,
                        ),
                        child: Row(
                            children: <Widget>[
                                UserAPI.getAvatarWidget(size: 54.0),
                                Constants.emptyDivider(width: 16.0),
                                Text(
                                    _user.name,
                                    style: TextStyle(
                                        fontSize: Constants.size(20.0),
                                        fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                ),
                            ],
                        ),
                    ),
                    ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Constants.separator(context),
                        itemCount: settingsSection.length,
                        itemBuilder: (context, index) => settingSectionListView(index),
                    ),
                ],
            ),
        );
    }
}
