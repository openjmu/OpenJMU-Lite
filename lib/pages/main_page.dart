import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/pages/app_center_page.dart';
import 'package:openjmu_lite/pages/course_schedule_page.dart';
import 'package:openjmu_lite/pages/score_page.dart';

@FFRoute(name: 'openjmu-lite://main-page', routeName: '首页')
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<IconData> _bottomIcons = [
    Icons.date_range,
    Icons.receipt,
    Icons.widgets,
  ];
  Color themeColor = Configs.appThemeColor;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    trueDebugPrint(UserAPI.currentUser.toString());

    Instances.eventBus.on<LogoutEvent>().listen((event) {
      Navigator.of(event.context)
          .pushReplacementNamed(Routes.openjmuLiteLoginPage);
    });
  }

  void selectItem(index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData _m = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: StackAppBarWithSlot(
        title: Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          bottom: _m.padding.bottom + _m.viewInsets.bottom,
          child: IndexedStack(
            index: _index,
            children: <Widget>[
              CourseSchedulePage(),
              ScorePage(),
              AppCenterPage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Themes.isDark
                  ? Theme.of(context).canvasColor
                  : Theme.of(context).dividerColor,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Theme.of(context).primaryColor,
          elevation: 0.0,
          child: Container(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int i = 0; i < _bottomIcons.length; i++)
                  BottomAppBarItem(
                    icon: Icon(_bottomIcons[i]),
                    onPressed: () {
                      selectItem(i);
                    },
                    selected: _index == i,
                    selectedColor: Configs.appThemeColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomAppBarItem extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;
  final Color unselectedColor;
  final Color selectedColor;
  final bool selected;

  const BottomAppBarItem({
    Key key,
    @required this.icon,
    @required this.onPressed,
    @required this.selected,
    this.selectedColor,
    this.unselectedColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: IconTheme(
        data: IconThemeData(
          color: selected
              ? selectedColor ?? Theme.of(context).primaryColor
              : unselectedColor,
        ),
        child: icon,
      ),
      onPressed: onPressed,
    );
  }
}

class StackAppBarWithSlot extends StatelessWidget {
  final Widget title;

  const StackAppBarWithSlot({Key key, @required this.title}) : super(key: key);

  Widget avatar(context) {
    return SizedBox.fromSize(
      size: Size.square(suSetHeight(kAppBarHeight / 1.5)),
      child: GestureDetector(
        child: UserAPI.getAvatarWidget(),
        onTap: () {
          Navigator.of(context).pushNamed(Routes.openjmuLiteSettingsPage);
        },
      ),
    );
  }

  Widget scan(context) {
    final double size = suSetHeight(kAppBarHeight / 1.5);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(125),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          "assets/icons/scan.svg",
          color: Colors.white,
          width: size / 2,
          height: size / 2,
        ),
        onPressed: () async {
          final bool isAllGranted =
              await checkPermissions(<Permission>[Permission.camera]);
          if (isAllGranted) {
            Navigator.of(context).pushNamed("/scanqrcode");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        title,
        Positioned(
          top: Screens.topSafeHeight + suSetHeight(kAppBarHeight),
          left: 0.0,
          right: 0.0,
          height: 1.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor)),
            ),
          ),
        ),
        Positioned(
          top: Screens.topSafeHeight,
          left: 4.0,
          width: 56.0,
          height: suSetHeight(kAppBarHeight),
          child: Center(child: avatar(context)),
        ),
        Positioned(
          top: Screens.topSafeHeight,
          right: 4.0,
          width: 56.0,
          height: suSetHeight(kAppBarHeight),
          child: Center(child: scan(context)),
        ),
      ],
    );
  }
}
