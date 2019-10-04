import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/configs.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/pages/web_page.dart';
import 'package:openjmu_lite/utils/data_utils.dart';


class LoginPage extends StatefulWidget {
    @override
    _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _usernameController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();

    String _username = "";
    String _password = "";

    bool _isObscure = true, _isLoading = false;
    Color _defaultIconColor = Colors.grey;

    @override
    void initState() {
        Constants.eventBus
            ..on<LoginEvent>().listen((event) {
                if (!event.isWizard) {}
                Navigator.of(event.context).pushReplacementNamed("/main");
            })
            ..on<LoginFailedEvent>().listen((event) {
                _isLoading = false;
                if (mounted) setState(() {});
            })
        ;
        _usernameController..addListener(() {
            if (this.mounted) {
                _username = _usernameController.text;
            }
        });
        _passwordController..addListener(() {
            if (this.mounted) {
                _password = _passwordController.text;
            }
        });
        super.initState();
    }
    @override
    void dispose() {
        _usernameController?.dispose();
        _passwordController?.dispose();
        super.dispose();
    }

    Widget logo() {
        return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
                Text(
                    "OpenJMU",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.size(40.0),
                        fontWeight: FontWeight.bold,
                        fontFamily: "ProductSans",
                        letterSpacing: 1.0,
                    ),
                ),
                SizedBox(height: Constants.size(10.0),),
                Container(
                    color: Color(0x99ffffff),
                    padding: EdgeInsets.only(
                        left: Constants.size(8.0),
                        right: Constants.size(8.0),
                        top: Constants.size(4.0),
                    ),
                    child: Text(
                        "LITE",
                        style: TextStyle(
                            color: Configs.appThemeColor,
                            fontSize: Constants.size(20.0),
                            fontWeight: FontWeight.bold,
                            fontFamily: "ProductSans",
                            letterSpacing: Constants.size(4.0),
                        ),
                    ),
                ),
            ],
        );
    }

    Widget loginForm() {
        return Form(
            key: _formKey,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    usernameTextField(),
                    passwordTextField(),
                ],
            ),
        );
    }

    Widget usernameTextField() {
        return Container(
            margin: EdgeInsets.only(bottom: Constants.size(30.0)),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.size(16.0)),
                color: Colors.grey.withAlpha(60),
            ),
            child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: Constants.size(12.0),
                        horizontal: Constants.size(16.0),
                    ),
                    labelText: '工号/学号',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: Constants.size(18.0),
                    ),
                ),
                style: TextStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontSize: Constants.size(18.0),
                ),
                cursorColor: Configs.appThemeColor,
                onSaved: (String value) => _username = value,
                validator: (String value) {
                    if (value.isEmpty) return '请输入账户';
                    return null;
                },
                keyboardType: TextInputType.number,
            ),
        );
    }

    Widget passwordTextField() {
        return Container(
            margin: EdgeInsets.only(bottom: Constants.size(30.0),),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.size(16.0)),
                color: Colors.grey.withAlpha(60),
            ),
            child: TextFormField(
                controller: _passwordController,
                onSaved: (String value) => _password = value,
                obscureText: _isObscure,
                validator: (String value) {
                    if (value.isEmpty) return '请输入密码';
                    return null;
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        vertical: Constants.size(12.0),
                        horizontal: Constants.size(16.0),
                    ),
                    labelText: '密码',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: Constants.size(18.0),
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                            color: _defaultIconColor,
                            size: Constants.size(20.0),
                        ),
                        onPressed: () {
                            setState(() {
                                _isObscure = !_isObscure;
                                _defaultIconColor = _isObscure
                                        ? Colors.grey
                                        : Configs.appThemeColor;
                            });
                        },
                    ),
                ),
                style: TextStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontSize: Constants.size(18.0),
                ),
                cursorColor: Configs.appThemeColor,
            ),
        );
    }

    Widget loginButton(context) {
        return Container(
            margin: EdgeInsets.only(bottom: Constants.size(20.0)),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Constants.size(16.0)),
                color: Configs.appThemeColor,
            ),
            child: !_isLoading
                    ?
            FlatButton(
                padding: EdgeInsets.symmetric(
                    vertical: Constants.size(17.0),
                ),
                onPressed: () { loginButtonPressed(context); },
                child: Text(
                    "登录",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: Constants.size(20.0),
                        fontWeight: FontWeight.bold,
                    ),
                ),
            )
                    :
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                    Padding(
                        padding: EdgeInsets.symmetric(vertical: Constants.size(17.0)),
                        child: SizedBox(
                            width: Constants.size(24.0),
                            height: Constants.size(24.0),
                            child: Constants.progressIndicator(color: Colors.white),
                        ),
                    ),
                ],
            ),
        );
    }

    Widget actions(context) {
        return RichText(text: TextSpan(
            style: TextStyle(
                fontSize: Constants.size(13.0),
                color: Colors.grey[900],
            ),
            children: <TextSpan>[
                TextSpan(
                    text: "忘记密码",
                    recognizer: TapGestureRecognizer()
                        ..onTap = () => forgotPassword(context)
                    ,
                ),
                TextSpan(
                    text: "　|　",
                ),
                TextSpan(
                    text: "查询工号",
                    recognizer: TapGestureRecognizer()
                        ..onTap = () => searchWorkId(context),
                ),
            ]
        ));
    }

    void loginButtonPressed(context) {
        if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            setState(() {
                _isLoading = true;
            });
            DataUtils.login(context, _username, _password).catchError((e) {
                setState(() {
                    _isLoading = false;
                });
            });
        }
    }

    void searchWorkId(context) {
        print("searchWorkId");
        return WebPage.jump(
            context,
            "http://myid.jmu.edu.cn/ids/EmployeeNoQuery.aspx",
            "集大通行证 - 工号查询",
        );
    }

    void forgotPassword(context) async {
        return showPlatformDialog<Null>(
            context: context,
            builder: (BuildContext dialogContext) {
                return PlatformAlertDialog(
                    title: Text('忘记密码'),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                                Text('找回密码详见'),
                                Text('网络中心主页 -> 集大通行证'),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text('返回'),
                            onPressed: () {
                                Navigator.of(dialogContext).pop();
                            },
                        ),
                        FlatButton(
                            child: Text('查看'),
                            onPressed: () {
                                Navigator.of(dialogContext).pop();
                                return WebPage.jump(
                                    context,
                                    "https://net.jmu.edu.cn/info/1309/2476.htm",
                                    "集大通行证登录说明",
                                    withCookie: false,
                                );
                            },
                        ),
                    ],
                );
            },
        );
    }


    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: Configs.appThemeColor,
            body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    Expanded(child: Center(child: logo())),
                    ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Constants.size(30.0),),
                            topRight: Radius.circular(Constants.size(30.0),),
                        ),
                        child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(Constants.size(40.0),),
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                    loginForm(),
                                    loginButton(context),
                                    actions(context),
                                ],
                            ),
                        ),
                    )
                ],
            ),
        );
    }
}
