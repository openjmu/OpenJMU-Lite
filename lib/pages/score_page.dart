import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:openjmu_lite/apis/api.dart';
import 'package:openjmu_lite/apis/user_api.dart';
import 'package:openjmu_lite/beans/bean.dart';
import 'package:openjmu_lite/beans/event.dart';
import 'package:openjmu_lite/constants/configs.dart';
import 'package:openjmu_lite/constants/constants.dart';
import 'package:openjmu_lite/constants/themes.dart';
import 'package:openjmu_lite/utils/socket_utils.dart';
import 'package:openjmu_lite/widgets/stack_appbar.dart';


class ScorePage extends StatefulWidget {
    @override
    State<StatefulWidget> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
    final Color currentThemeColor = Configs.appThemeColor;
    final Map<String, Map<String, double>> fiveBandScale = {
        "优秀": {
            "score": 95.0,
            "point": 4.625,
        },
        "良好": {
            "score": 85.0,
            "point": 3.875,
        },
        "中等": {
            "score": 75.0,
            "point": 3.125,
        },
        "及格": {
            "score": 65.0,
            "point": 2.375,
        },
        "不及格": {
            "score": 55.0,
            "point": 0.0,
        },
    };
    final Map<String, Map<String, double>> twoBandScale = {
        "合格": {
            "score": 80.0,
            "point": 3.5,
        },
        "不合格": {
            "score": 50.0,
            "point": 0.0,
        },
    };
    bool loading = true, socketInitialized = false, noScore = false, loadError = false;
    List<String> terms;
    List<Score> scores = [], scoresFiltered;
    String termSelected;
    String _scoreData = "";
    Widget errorWidget = SizedBox();
    StreamSubscription scoresSubscription;

    @override
    void initState() {
        loadScores();
        Constants.eventBus
            ..on<ScoreRefreshEvent>().listen((event) {
                if (this.mounted) {
                    resetScores();
                    setState(() { loading = true; });
                    loadScores();
                }
            });
        super.initState();
    }

    @override
    void dispose() {
        super.dispose();
        unloadSocket();
    }

    void sendRequest() {
        String requestData = jsonEncode({
            "uid": "${UserAPI.currentUser.uid}",
            "sid": "${UserAPI.currentUser.sid}",
            "workid": "${UserAPI.currentUser.workId}",
        });
        SocketUtils.mSocket.add(utf8.encode(requestData));
    }

    void loadScores() async {
        if (!socketInitialized) {
            SocketUtils.initSocket(API.scoreSocket).then((whatever) {
                socketInitialized = true;
                scoresSubscription = utf8.decoder
                        .bind(SocketUtils.mStream)
                        .listen(onReceive)
                ;
                sendRequest();
            }).catchError((e) {
                debugPrint("Socket connect error: $e");
                fetchError(e.toString());
            });
        } else {
            debugPrint("Socket already initialized.");
            sendRequest();
        }
    }

    void resetScores() {
        unloadSocket();
        terms = null;
        scores.clear();
        scoresFiltered = null;
        _scoreData = "";
    }

    void unloadSocket() {
        socketInitialized = false;
        scoresSubscription?.cancel();
        SocketUtils.unInitSocket();
    }

    void onReceive(data) async {
        _scoreData += data;
        if (_scoreData.endsWith("]}}")) {
            try {
                Map<String, dynamic> response = json.decode(_scoreData)['obj'];
                if (response['terms'].length == 0 || response['scores'].length == 0) {
                    noScore = true;
                } else {
                    terms = List<String>.from(response['terms']);
                    termSelected = terms.last;
                    List _scores = response['scores'];
                    _scores.forEach((score) {
                        scores.add(Score.fromJson(score));
                    });
                    scoresFiltered = List.from(scores);
                    if (scoresFiltered.length > 0) scoresFiltered.removeWhere((score) {
                        return score.termId != (termSelected != null ? termSelected : terms.last);
                    });
                }
                loading = false;
                if (mounted) setState(() {});
            } catch (e) {
                debugPrint("$e");
            }
        }
    }

    void selectTerm(int index) {
        if (termSelected != terms[index]) setState(() {
            termSelected = terms[index];
            scoresFiltered = List.from(scores);
            if (scoresFiltered.length > 0) scoresFiltered.removeWhere((score) {
                return score.termId != (termSelected != null ? termSelected : terms.last);
            });
        });
    }

    bool isPass(score) {
        bool result;
        if (double.tryParse(score) != null) {
            if (double.parse(score) < 60.0) {
                result = false;
            } else {
                result = true;
            }
        } else {
            if (fiveBandScale.containsKey(score)) {
                if (fiveBandScale[score]['score'] >= 60.0) {
                    result = true;
                } else {
                    result = false;
                }
            } else if (twoBandScale.containsKey(score)) {
                if (twoBandScale[score]['score'] >= 60.0) {
                    result = true;
                } else {
                    result = false;
                }
            } else {
                result = false;
            }
        }
        return result;
    }

    void fetchError(String error) {
        String result;

        if (error.contains("The method 'transform' was called on null")) {
            result = "电波暂时无法到达成绩业务的门口\n😰";
        } else {
            result = "成绩好像还没有准备好呢\n🤒";
        }

        loading = false; loadError = true;
        errorWidget = Center(
            child: Text(
                result,
                style: TextStyle(
                    fontSize: Constants.size(23.0),
                    fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
            ),
        );
        if (mounted) setState(() {});
    }

    Widget termsWidget(context) {
        return Center(child: Container(
            padding: EdgeInsets.symmetric(
                vertical: Constants.size(5.0),
            ),
            height: Constants.size(80.0),
            child: ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: terms.length + 2,
                itemBuilder: (context, index) {
                    if (index == 0 || index == terms.length + 1) {
                        return SizedBox(width: Constants.size(5.0));
                    } else {
                        return _term(
                            terms[terms.length - index ],
                            terms.length - index,
                        );
                    }
                },
            ),
        ));
    }

    Widget _term(term, index) {
        String _term = term.toString();
        int currentYear = int.parse(_term.substring(0, 4));
        int currentTerm = int.parse(_term.substring(4, 5));
        return GestureDetector(
            onTap: () {
                selectTerm(index);
            },
            child: Container(
                padding: EdgeInsets.all(Constants.size(6.0)),
                child: DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Constants.size(10.0)),
                        boxShadow: <BoxShadow>[
                            BoxShadow(
                                blurRadius: 5.0,
                                color: Theme.of(context).canvasColor,
                            ),
                        ],
                        color: _term == termSelected
                                ? Configs.appThemeColor
                                : Theme.of(context).canvasColor
                        ,
                    ),
                    child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Constants.size(8.0),
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                                Text(
                                    "$currentYear-${currentYear+1}",
                                    style: TextStyle(
                                        color: _term == termSelected
                                                ? Colors.white
                                                : Theme.of(context).textTheme.body1.color
                                        ,
                                        fontWeight: _term == termSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal
                                        ,
                                        fontSize: Constants.size(14.0),
                                    ),
                                ),
                                Text(
                                    "第$currentTerm学期",
                                    style: TextStyle(
                                        color: _term == termSelected
                                                ? Colors.white
                                                : Theme.of(context).textTheme.body1.color
                                        ,
                                        fontWeight: _term == termSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal
                                        ,
                                        fontSize: Constants.size(16.0),
                                    ),
                                ),
                            ],
                        ),
                    ),
                ),
            ),
        );
    }

    Widget _statusIndicator(Score score) {
        Color color = Themes.scorePassed[isPass(score.score)];
        return Container(
            margin: const EdgeInsets.only(right: 8.0),
            width: Constants.size(8.0),
            height: Constants.size(36.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                ),
                color: color,
            ),
        );
    }

    Widget _name(Score score) {
        return Expanded(
            child: Text(
                "${score.courseName}",
                style: Theme.of(context).textTheme.title.copyWith(
                    fontSize: Constants.size(20.0),
                    fontWeight: FontWeight.w300,
                ),
                softWrap: false,
                overflow: TextOverflow.fade,
            ),
        );
    }

    Widget _score(Score score) {
        var _score = score.score;
        bool pass = isPass(_score);
        double _scorePoint;
        if (double.tryParse(_score) != null) {
            _score = double.parse(_score).toStringAsFixed(1);
            _scorePoint = (double.parse(_score) - 50) / 10;
            if (_scorePoint < 1.0) _scorePoint = 0.0;
        } else {
            if (fiveBandScale.containsKey(_score)) {
                _scorePoint = fiveBandScale[_score]['point'];
            } else if (twoBandScale.containsKey(_score)) {
                _scorePoint = twoBandScale[_score]['point'];
            } else {
                _scorePoint = 0.0;
            }
        }

        return Container(
            margin: const EdgeInsets.only(left: 8.0),
            padding: const EdgeInsets.only(right: 4.0),
            child: RichText(
                text: TextSpan(
                    children: <TextSpan>[
                        TextSpan(
                            text: "$_score",
                            style: Theme.of(context).textTheme.title.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Themes.scorePassed[pass],
                            ),
                        ),
                        TextSpan(
                            text: " / ",
                        ),
                        TextSpan(
                            text: "$_scorePoint",
                        ),
                    ],
                    style: Theme.of(context).textTheme.body1.copyWith(
                        fontSize: Constants.size(20.0),
                    ),
                ),
            ),
        );
    }

    Widget _timeAndPoint(Score score) {
        return Text(
            "学时: ${score.creditHour}　"
                    "学分: ${score.credit.toStringAsFixed(1)}",
            style: Theme.of(context).textTheme.body1.copyWith(
                fontSize: Constants.size(18.0),
                fontWeight: FontWeight.w300,
            ),
        );
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: StackAppBar(
                child: SizedBox(),
            ),
            body: loading ?
            Center(child: Constants.progressIndicator())
                    : loadError
                    ? errorWidget
                    :
            noScore ? Center(child: Text(
                "暂时还没有你的成绩\n🤔",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: Constants.size(30.0)),
            )) : scoresFiltered != null ? ListView.separated(
                padding: EdgeInsets.zero,
                separatorBuilder: (_, __) => Constants.separator(context, height: 1.0),
                itemCount: scoresFiltered.length,
                itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                        ),
                        child: Row(
                            children: <Widget>[
                                _statusIndicator(scoresFiltered[index]),
                                _name(scoresFiltered[index]),
                                _score(scoresFiltered[index]),
                            ],
                        ),
                    );
                },
            ) : SizedBox(),
        );
    }
}
