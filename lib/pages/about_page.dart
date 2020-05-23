import 'package:flutter/material.dart';

import 'package:openjmu_lite/constants/constants.dart';

@FFRoute(name: 'openjmu-lite://about', routeName: '关于页')
class AboutPage extends StatelessWidget {
  Widget about(context) {
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
              child: RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: "OpenJmu Lite",
                      style: TextStyle(
                        fontFamily: 'chocolate',
                        color: Configs.appThemeColor,
                        fontSize: Constants.size(50.0),
                      ),
                    ),
                    if (PackageUtils.version != null)
                      TextSpan(
                        text: "　v${PackageUtils.version}",
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: Constants.size(20.0)),
            RichText(
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(text: "Developed By "),
                  TextSpan(
                    text: "OpenJmu Team",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontFamily: 'chocolate',
                      fontSize: Constants.size(24.0),
                    ),
                  ),
                  TextSpan(text: " ."),
                ],
              ),
            ),
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
          "关于OpenJMU Lite",
          style: Theme.of(context).textTheme.headline6.copyWith(
                color: Colors.white,
                fontSize: Constants.size(21.0),
              ),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          about(context),
          SizedBox(height: Constants.size(100.0))
        ],
      ),
    );
  }
}
