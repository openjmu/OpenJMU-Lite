import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info/package_info.dart';

import 'package:openjmu_lite/constants/constants.dart';

class AboutPage extends StatefulWidget {
    @override
    _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
    String currentVersion;

    @override
    void initState() {
        super.initState();
        getCurrentVersion().then((version) {
            setState(() {
                currentVersion = version;
            });
        });
    }

    Future<String> getCurrentVersion() async {
        try {
            final PackageInfo packageInfo = await PackageInfo.fromPlatform();
            final String version = packageInfo.version;
            return version;
        } on PlatformException {
            return 'Failed to get project version.';
        }
    }

    Widget about() {
        return Container(
            padding: EdgeInsets.all(Constants.size(20.0)),
            child: Center(
                child: Column(
                    children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: Constants.size(12.0)),
                            child: Image.asset(
                                "images/jmu_logo_circle.png",
                                width: Constants.size(120.0),
                                height: Constants.size(120.0),
                            ),
                            decoration: BoxDecoration(shape: BoxShape.circle),
                        ),
                        SizedBox(height: Constants.size(30.0)),
                        Container(
                            margin: EdgeInsets.only(bottom: Constants.size(12.0)),
                            child: RichText(text: TextSpan(children: <TextSpan>[
                                TextSpan(
                                    text: "OpenJmu Lite",
                                    style: TextStyle(
                                        fontFamily: 'chocolate',
                                        color: Constants.appThemeColor,
                                        fontSize: Constants.size(50.0),
                                    ),
                                ),
                                TextSpan(text: "　v$currentVersion", style: Theme.of(context).textTheme.subtitle),
                            ])),
                        ),
                        SizedBox(height: Constants.size(20.0)),
                        RichText(text: TextSpan(
                            children: <TextSpan>[
                                TextSpan(
                                    text: "Developed By ",
                                    style: TextStyle(
                                        color: Theme.of(context).textTheme.body1.color,
                                    ),
                                ),
                                TextSpan(
                                    text: "Alex Vincent",
                                    style: TextStyle(
                                        color: Colors.lightBlue,
                                        fontFamily: 'chocolate',
                                        fontSize: Constants.size(24.0),
                                    ),
                                ),
                                TextSpan(text: " .", style: TextStyle(color: Theme.of(context).textTheme.body1.color)),
                            ],
                        )),
                        SizedBox(height: Constants.size(80.0)),
                    ],
                ),
            ),
        );
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    "关于OpenJMU",
                    style: Theme.of(context).textTheme.title.copyWith(
                        color: Colors.white,
                        fontSize: Constants.size(21.0),
                    ),
                ),
                centerTitle: true,
            ),
            body: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    about(),
                    SizedBox(height: Constants.size(100.0))
                ],
            ),
        );
    }
}
