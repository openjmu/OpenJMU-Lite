import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:openjmu_lite/beans/event.dart';
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

    BuildContext pageContext;

    String _username = "";
    String _password = "";

    bool _isObscure = true, _isLoading = false;
    Color _defaultIconColor = Colors.grey;

    @override
    void initState() {
        Constants.eventBus
            ..on<LoginEvent>().listen((event) {
                if (!event.isWizard) {}
                Navigator.of(pageContext).pushReplacementNamed("/main");
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
                        fontSize: 50.0,
                        fontWeight: FontWeight.bold,
                    ),
                ),
                SizedBox(height: 20.0),
                Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "LITE",
                        style: TextStyle(
                            color: Constants.appThemeColor,
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8.0,
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
            margin: EdgeInsets.only(bottom: 30.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.grey.withAlpha(60),
            ),
            child: TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                    labelText: '工号/学号',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 20.0,
                    ),
                ),
                style: TextStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontSize: 20.0,
                ),
                cursorColor: Constants.appThemeColor,
                onSaved: (String value) => _username = value,
                validator: (String value) {
                    if (value.isEmpty) return '请输入账户';
                },
                keyboardType: TextInputType.number,
            ),
        );
    }

    Widget passwordTextField() {
        return Container(
            margin: EdgeInsets.only(bottom: 30.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.grey.withAlpha(60),
            ),
            child: TextFormField(
                controller: _passwordController,
                onSaved: (String value) => _password = value,
                obscureText: _isObscure,
                validator: (String value) {
                    if (value.isEmpty) return '请输入密码';
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.0),
                    labelText: '密码',
                    labelStyle: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 20.0,
                    ),
                    suffixIcon: IconButton(
                        icon: Icon(
                            _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                            color: _defaultIconColor,
                            size: 24.0,
                        ),
                        onPressed: () {
                            setState(() {
                                _isObscure = !_isObscure;
                                _defaultIconColor = _isObscure
                                        ? Colors.grey
                                        : Constants.appThemeColor;
                            });
                        },
                    ),
                ),
                style: TextStyle(
                    color: Theme.of(context).textTheme.title.color,
                    fontSize: 20.0,
                ),
                cursorColor: Constants.appThemeColor,
            ),
        );
    }

    Widget loginButton(context) {
        return Container(
            margin: EdgeInsets.only(bottom: 20.0),
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Constants.appThemeColor,
            ),
            child: !_isLoading
                    ?
            FlatButton(
                padding: EdgeInsets.symmetric(
                    vertical: 18.0,
                ),
                onPressed: () { loginButtonPressed(context); },
                child: Text(
                    "登录",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold
                    ),
                ),
            )
                    :
            Container(
                height: 65.0,
                child: Constants.progressIndicator(color: Colors.white),
            )
            ,
        );
    }

    Widget actions(context) {
        return RichText(text: TextSpan(
            style: TextStyle(
                fontSize: 16.0,
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
        pageContext = context;
        return Scaffold(
            backgroundColor: Constants.appThemeColor,
            body: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    Expanded(
                        child: Center(
                            child: logo(),
                        ),
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                        ),
                        child: Container(
                            color: Colors.white,
                            padding: EdgeInsets.all(40.0),
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
