import 'package:flutter/material.dart';

import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/utils/data_utils.dart';


class MainPage extends StatefulWidget {
    @override
    _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
    BuildContext pageContext;

    @override
    void initState() {
        Constants.eventBus.on<LogoutEvent>().listen((event) {
            Navigator.of(context).pushReplacementNamed("/login");
        });
        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        pageContext = context;
        return Scaffold(
            appBar: AppBar(
                title: Text("${UserAPI.currentUser.name}"),
                actions: <Widget>[
                    IconButton(
                        icon: Icon(Icons.exit_to_app),
                        onPressed: () {
                            DataUtils.logout();
                        },
                    )
                ],
            ),
        );
    }
}
