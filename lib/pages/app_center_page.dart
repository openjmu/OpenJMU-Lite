import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/utils/net_utils.dart';
import 'package:openjmu_lite/pages/web_page.dart';


class AppCenterPage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => AppCenterPageState();
}

class AppCenterPageState extends State<AppCenterPage>
        with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
    final ScrollController _scrollController = ScrollController();

    Color currentThemeColor = Constants.appThemeColor;
    Map<String, List<Widget>> webAppWidgetList = {};
    List<Widget> webAppList = [];
    List webAppListData;
    int listTotalSize = 0;

    Future _futureBuilderFuture;

    @override
    bool get wantKeepAlive => true;

    @override
    void initState() {
        _futureBuilderFuture = getAppList();
        super.initState();
    }

    WebApp createWebApp(webAppData) {
        return WebApp(
            id: webAppData['appid'],
            sequence: webAppData['sequence'],
            code: webAppData['code'],
            name: webAppData['name'],
            url: webAppData['url'],
            menuType: webAppData['menutype'],
        );
    }

    Future getAppList() async => NetUtils.getWithCookieSet(API.webAppLists);

    Widget categoryListView(BuildContext context, AsyncSnapshot snapshot) {
        List<dynamic> data = snapshot.data?.data;
        Map<String, List<Widget>> appList = {};
        for (var i = 0; i < data.length; i++) {
            String url = data[i]['url'];
            String name = data[i]['name'];
            if ((url != "" && url != null) && (name != "" && name != null)) {
                WebApp _app = createWebApp(data[i]);
                WebApp.category().forEach((name, value) {
                    if (_app.menuType == name) {
                        if (appList[name.toString()] == null) {
                            appList[name.toString()] = [];
                        }
                        appList[name].add(getWebAppButton(_app));
                    }
                });
            }
        }
        webAppWidgetList = appList;
        List<Widget> _list = [];
        WebApp.category().forEach((name, value) {
            _list.add(getSectionColumn(context, name));
        });
        return ListView.builder(
            controller: _scrollController,
            itemCount: _list.length,
            itemBuilder: (BuildContext context, index) => _list[index],
        );
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

    Widget getWebAppButton(webApp) {
        String url = replaceParamsInUrl(webApp.url);
        String imageUrl = "${API.webAppIcons}"
                "appid=${webApp.id}"
                "&code=${webApp.code}"
        ;
        Widget button = FlatButton(
            padding: EdgeInsets.zero,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    SizedBox(
                        width: Constants.size(68.0),
                        height: Constants.size(68.0),
                        child: CircleAvatar(
                            backgroundColor: Theme.of(context).dividerColor,
                            child: Image(
                                width: Constants.size(44.0),
                                height: Constants.size(44.0),
                                image: CachedNetworkImageProvider(imageUrl, cacheManager: DefaultCacheManager()),
                                fit: BoxFit.cover,
                            ),
                        ),
                    ),
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
        return button;
    }

    Widget getSectionColumn(context, name) {
        if (webAppWidgetList[name] != null) {
            return Column(
                children: <Widget>[
                    Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: Constants.size(36.0),
                            vertical: Constants.size(8.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: Constants.size(8.0)),
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Text(
                                WebApp.category()[name],
                                style: TextStyle(
                                    color: Theme.of(context).textTheme.title.color,
                                    fontSize: Constants.size(18.0),
                                    fontWeight: FontWeight.bold,
                                ),
                            ),
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: Divider.createBorderSide(
                                    context,
                                    color: Theme.of(context).dividerColor,
                                    width: 2.0,
                                ),
                            ),
                        ),
                    ),
                    GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        crossAxisCount: 3,
                        childAspectRatio: 1.3 / 1,
                        children: webAppWidgetList[name],
                    ),
                ],
            );
        } else {
            return SizedBox();
        }
    }

    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);
        return RefreshIndicator(
            child: FutureBuilder(
                builder: _buildFuture,
                future: _futureBuilderFuture,
            ),
            onRefresh: getAppList,
        );
    }
}
