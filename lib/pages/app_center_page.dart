import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/constants/configs.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/utils/net_utils.dart';
import 'package:openjmu_lite/pages/web_page.dart';
import 'package:openjmu_lite/widgets/stack_appbar.dart';


class AppCenterPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage> with SingleTickerProviderStateMixin {
    final ScrollController _scrollController = ScrollController();

    Color currentThemeColor = Configs.appThemeColor;
    Map<String, List<Widget>> webAppWidgetList = {};

    Future _futureBuilderFuture;

    @override
    void initState() {
        _futureBuilderFuture = getAppList();
        super.initState();
    }

    Future getAppList() async => NetUtils.get(API.webAppLists);

    Widget categoryListView(BuildContext context, AsyncSnapshot snapshot) {
        List<dynamic> data = snapshot.data?.data;
        Map<String, List<Widget>> appList = {};
        for (int i = 0; i < data.length; i++) {
            String url = data[i]['url'];
            String name = data[i]['name'];
            if (
            (url != "" && url != null)
                    &&
                    (name != "" && name != null)
            ) {
                WebApp _app = WebApp.fromJson(data[i]);
                _app = appWrapper(_app);
                if (appList[_app.menuType] == null) {
                    appList[_app.menuType] = [];
                }
                if (!appFiltered(_app)) appList[_app.menuType].add(getWebAppButton(_app));
            }
        }
        webAppWidgetList = appList;
        List<Widget> _list = [];
        WebApp.category.forEach((name, value) {
            _list.add(getSectionColumn(context, name));
        });
        return ListView.builder(
            controller: _scrollController,
            itemCount: _list.length,
            itemBuilder: (BuildContext context, index) => _list[index],
        );
    }

    WebApp appWrapper(WebApp app) {
//        print("${app.code}-${app.name}");
        switch (app.name) {
//            case "集大通":
//                app.name = "OpenJMU";
//                app.url = "https://openjmu.jmu.edu.cn/";
//                break;
            default:
                break;
        }
        return app;
    }

    bool appFiltered(WebApp app) {
        if (
            (!UserAPI.currentUser.isCY && app.code == "6101")
                ||
            (UserAPI.currentUser.isCY && app.code == "5001")
                ||
            (app.code == "6501")
                ||
            (app.code == "4001" && app.name == "集大通")
        ) {
            return true;
        } else {
            return false;
        }
    }

    Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
            case ConnectionState.none:
                return Center(child: Text('尚未加载'));
            case ConnectionState.active:
                return Center(child: Text('正在加载'));
            case ConnectionState.waiting:
                return Center(
                    child: Constants.progressIndicator(),
                );
            case ConnectionState.done:
                if (snapshot.hasError) return Text('错误: ${snapshot.error}');
                return categoryListView(context, snapshot);
            default:
                return Center(child: Text('尚未加载'));
        }
    }

    String replaceParamsInUrl(url) {
        RegExp sidReg = RegExp(r"{SID}");
        RegExp uidReg = RegExp(r"{UID}");
        String result = url;
        result = result.replaceAllMapped(sidReg, (match) => UserAPI.currentUser.sid.toString());
        result = result.replaceAllMapped(uidReg, (match) => UserAPI.currentUser.uid.toString());
        return result;
    }

    Widget getWebAppButton(WebApp webApp) {
        final String url = replaceParamsInUrl(webApp.url);
        return FlatButton(
            padding: EdgeInsets.zero,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    AppIcon(app: webApp, size: 60.0),
                    Text(
                        webApp.name,
                        style: TextStyle(
                            fontSize: Constants.size(17.0),
                            color: Theme.of(context).textTheme.body1.color,
                            fontWeight: FontWeight.normal,
                        ),
                    ),
                ],
            ),
            onPressed: () => WebPage.jump(context, url, webApp.name),
        );
    }

    Widget getSectionColumn(context, name) {
        if (webAppWidgetList[name] != null) {
            return Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Theme.of(context).primaryColor,
                ),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                        Container(
                            padding: EdgeInsets.symmetric(
                                vertical: Constants.size(16.0),
                            ),
                            child: Center(
                                child: Text(
                                    WebApp.category[name],
                                    style: Theme.of(context).textTheme.body1.copyWith(
                                        fontSize: Constants.size(18.0),
                                    ),
                                ),
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Theme.of(context).dividerColor,
                                    ),
                                ),
                            ),
                        ),
                        GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: webAppWidgetList[name].length,
                            itemBuilder: (context, index) {
                                final int _rows = (webAppWidgetList[name].length / 3).ceil();
                                final bool showBottom = ((index + 1) / 3).ceil() != _rows;
                                final bool showRight = ((index + 1) / 3).ceil() != (index + 1) ~/ 3;
                                Widget _w = webAppWidgetList[name][index];
                                _w = DecoratedBox(
                                    decoration: BoxDecoration(
                                        border: Border(
                                            bottom: showBottom ? BorderSide(
                                                color: Theme.of(context).canvasColor,
                                            ) : BorderSide.none,
                                            right: showRight ? BorderSide(
                                                color: Theme.of(context).canvasColor,
                                            ) : BorderSide.none,
                                        ),
                                    ),
                                    child: _w,
                                );
                                return _w;
                            },
                        ),
                    ],
                ),
            );
        } else {
            return SizedBox();
        }
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Theme.of(context).canvasColor,
            appBar: StackAppBar(
                color: Theme.of(context).primaryColor,
            ),
            body: RefreshIndicator(
                child: FutureBuilder(
                    builder: _buildFuture,
                    future: _futureBuilderFuture,
                ),
                onRefresh: getAppList,
            ),
        );
    }
}

class AppIcon extends StatelessWidget {
    final WebApp app;
    final double size;

    AppIcon({
        Key key,
        @required this.app,
        this.size = 56.0,
    }) : super(key: key);


    Future<Widget> loadAsset(WebApp app) async {
        final String basePath = "assets/icons/appCenter";
        final String assetPath = "$basePath/${app.code}-${app.name}.svg";
        try {
            ByteData _ = await rootBundle.load(assetPath);
            return SvgPicture.asset(
                assetPath,
                width: size,
                height: size,
            );
        } catch (e) {
            final String imageUrl = "${API.webAppIcons}"
                    "appid=${app.id}"
                    "&code=${app.code}"
            ;
            return Image(
                image: CachedNetworkImageProvider(imageUrl, cacheManager: DefaultCacheManager()),
                fit: BoxFit.fill,
            );
        }
    }

    @override
    Widget build(BuildContext context) {
        return Configs.newAppCenterIcon ? FutureBuilder(
            initialData: SizedBox(),
            future: loadAsset(app),
            builder: (context, snapshot) {
                return SizedBox(
                    width: size,
                    height: size,
                    child: Center(
                        child: snapshot.data,
                    ),
                );
            },
        ) : SizedBox(
            width: 60,
            height: 60,
            child: Center(
                child: Image(
                    image: CachedNetworkImageProvider(
                        "${API.webAppIcons}"
                                "appid=${app.id}"
                                "&code=${app.code}",
                        cacheManager: DefaultCacheManager(),
                    ),
                    fit: BoxFit.fill,
                ),
            ),
        );
    }
}