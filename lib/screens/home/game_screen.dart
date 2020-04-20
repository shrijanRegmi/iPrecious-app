import 'dart:async';
import 'dart:math';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
  final _gameMod;
  final _amount;
  GameScreen(this._gameMod, this._amount) : super();
}

class _GameScreenState extends State<GameScreen> {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(
          value: DatabaseProvider(uid: _user.uid).userDetail,
        ),
        StreamProvider<Achievements>.value(
          value: DatabaseProvider(uid: _user.uid).achievement,
        ),
        StreamProvider<Points>.value(
          value: DatabaseProvider(uid: _user.uid).points,
        ),
      ],
      child: SafeArea(
        child: Scaffold(body: GameView(widget._gameMod, widget._amount)),
      ),
    );
  }
}

class GameView extends StatefulWidget {
  @override
  _GameViewState createState() => _GameViewState();
  final _gameMod;
  final _amount;
  GameView(this._gameMod, this._amount) : super();
}

class _GameViewState extends State<GameView> {
  AdmobInterstitial _interstitialAd = AdmobInterstitial(
    adUnitId: "ca-app-pub-4056821571384483/9120203477",
  );
  int _profileNum = 0;
  @override
  void initState() {
    super.initState();
    _getGuessNumber();
    _getDifficulty();
    _getOpponentDetails();
    var _rand = Random();
    setState(() {
      _profileNum = _rand.nextInt(52);
    });
  }

  _getOpponentDetails() {
    var _rand = Random();

    setState(() {
      _opponentName = faker.person.name();
      _opponentCoins = _rand.nextInt(20000).toString();
      _opponentGems = _rand.nextInt(100).toString();
      _opponentCash = _rand.nextInt(1500).toString();
    });
  }

  String _opponentName = "";
  String _opponentCoins = "";
  String _opponentGems = "";
  String _opponentCash = "";

  TextEditingController _myNumController = TextEditingController();

  double _height = 100.0;

  bool _showCircularProgressBar = false;
  bool _isOpponentWaiting = false;
  bool _mySectionIsEnable = true;

  int _theNumber = 0;
  int _opponentNumber = 0;
  int a = 2;
  int min = 0;
  int max = 500;
  int _difficulty;

  String _myNumberState;
  String _opponentNumberState = "";

  _getDifficulty() {
    var _rand = Random();
    _difficulty = _rand.nextInt(10);
    // _difficulty = 8;
    // print(_difficulty);
  }

  _getGuessNumber() {
    var _rand = Random();
    setState(() {
      _theNumber = _rand.nextInt(500);
      print(_theNumber);
    });
  }

  _getOpponentNumber(final _user, final _achievement, final _points) {
    var _rand = Random();
    var r = min + _rand.nextInt(max - min);
    // print("($r,$_theNumber)($min,$max)");
    setState(() {
      _opponentNumber = r;
      _isOpponentWaiting = true;
      _mySectionIsEnable = false;
    });

    if (_difficulty.isEven) {
      if (_difficulty == 8) {
        if (_opponentNumber > _theNumber) {
          setState(() {
            max = _opponentNumber;
          });
          var r = min + _rand.nextInt(max - min);
          setState(() {
            _opponentNumber = r;
          });

          if (_opponentNumber > _theNumber) {
            setState(() {
              max = _opponentNumber;
            });
            var r = min + _rand.nextInt(max - min);
            setState(() {
              _opponentNumber = r;
            });

            if (_opponentNumber > _theNumber) {
              setState(() {
                max = _opponentNumber;
              });
            } else {
              setState(() {
                min = _opponentNumber;
              });
            }
          } else {
            setState(() {
              min = _opponentNumber;
            });
            var r = min + _rand.nextInt(max - min);
            setState(() {
              _opponentNumber = r;
            });

            if (_opponentNumber > _theNumber) {
              setState(() {
                max = _opponentNumber;
              });
            } else {
              setState(() {
                min = _opponentNumber;
              });
            }
          }
        } else {
          setState(() {
            min = _opponentNumber;
          });
          var r = min + _rand.nextInt(max - min);
          setState(() {
            _opponentNumber = r;
          });

          if (_opponentNumber > _theNumber) {
            setState(() {
              max = _opponentNumber;
            });
            var r = min + _rand.nextInt(max - min);
            setState(() {
              _opponentNumber = r;
            });

            if (_opponentNumber > _theNumber) {
              setState(() {
                max = _opponentNumber;
              });
            } else {
              setState(() {
                min = _opponentNumber;
              });
            }
          } else {
            setState(() {
              min = _opponentNumber;
            });
            var r = min + _rand.nextInt(max - min);
            setState(() {
              _opponentNumber = r;
            });

            if (_opponentNumber > _theNumber) {
              setState(() {
                max = _opponentNumber;
              });
            } else {
              setState(() {
                min = _opponentNumber;
              });
            }
          }
        }
      } else {
        if (_opponentNumber > _theNumber) {
          setState(() {
            max = _opponentNumber;
          });
          var r = min + _rand.nextInt(max - min);
          setState(() {
            _opponentNumber = r;
          });

          if (_opponentNumber > _theNumber) {
            setState(() {
              max = _opponentNumber;
            });
          } else {
            setState(() {
              min = _opponentNumber;
            });
          }
        } else {
          setState(() {
            min = _opponentNumber;
          });
          var r = min + _rand.nextInt(max - min);
          setState(() {
            _opponentNumber = r;
          });

          if (_opponentNumber > _theNumber) {
            setState(() {
              max = _opponentNumber;
            });
          } else {
            setState(() {
              min = _opponentNumber;
            });
          }
        }
      }
    } else {
      if (_opponentNumber > _theNumber) {
        setState(() {
          max = _opponentNumber;
        });
      } else {
        setState(() {
          min = _opponentNumber;
        });
      }
    }

    Timer(Duration(seconds: 5), () {
      setState(() {
        _isOpponentWaiting = false;
      });
      _isOpponentNumberCorrect(_user, _achievement, _points);
    });
  }

  _isOpponentNumberCorrect(final _user, final _achievement, final _points) {
    if (_opponentNumber == _theNumber) {
      _gameLost(_user, _achievement, _points);
      setState(() {
        _opponentNumberState = "Correct";
        _mySectionIsEnable = false;
      });
      _showWinLoseDialog();
      // _lost();
    } else if (_opponentNumber > _theNumber) {
      setState(() {
        _opponentNumberState = "Too high!";
        _mySectionIsEnable = true;
      });
    } else {
      setState(() {
        _opponentNumberState = "Too low!";
        _mySectionIsEnable = true;
      });
    }
  }

  _isMyNumberCorrect(final _user, final _achievement, final _points) {
    if (int.parse(_myNumController.text) > _theNumber) {
      setState(() {
        _myNumberState = "Too high!";
        _getOpponentNumber(_user, _achievement, _points);
      });
    } else if (int.parse(_myNumController.text) < _theNumber) {
      setState(() {
        _myNumberState = "Too low!";
        _getOpponentNumber(_user, _achievement, _points);
      });
    } else {
      _gameWon(_user, _achievement, _points);
      setState(() {
        _myNumberState = "Correct";
        _myNumController.clear();
        _mySectionIsEnable = false;
        _showWinLoseDialog();
      });
    }
  }

  _gameWon(final _user, final _achievement, final _points) async {
    await DatabaseProvider(uid: _user.uid).sendWinnerInfo(
        widget._gameMod,
        _user.userName,
        widget._amount,
        _user.userNcell,
        DateTime.now().toString());
    if (widget._gameMod == "Online with cash") {
      await DatabaseProvider(uid: _user.uid).updateUserPoints(
        cash: _points.cash + widget._amount + (widget._amount ~/ 1.5),
        coins: _points.coins,
        gems: _points.gems,
      );
    } else {
      await DatabaseProvider(uid: _user.uid).updateUserPoints(
        cash: _points.cash,
        coins: _points.coins +
            widget._amount +
            (widget._amount - 20 / 100 * widget._amount).toInt(),
        gems: _points.gems,
      );
    }

    await DatabaseProvider(uid: _user.uid).updateUserAchievements(
        gameWon: _achievement.gameWon + 1, gameLost: _achievement.gameLost);
  }

  _gameLost(final _user, final _achievement, final _points) async {
    await DatabaseProvider(uid: _user.uid).sendLoserInfo(
        widget._gameMod,
        _user.userName,
        widget._amount,
        _user.userNcell,
        DateTime.now().toString());

    await DatabaseProvider(uid: _user.uid).updateUserAchievements(
        gameWon: _achievement.gameWon, gameLost: _achievement.gameLost + 1);
  }

  Future<void> _showWinLoseDialog() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Center(
            child: StatefulBuilder(
              builder: (context, setState) {
                return Material(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 30.0),
                    width: MediaQuery.of(context).size.width - 100,
                    height: 400.0,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 100.0,
                          padding: const EdgeInsets.only(right: 30.0),
                          child: _numberSection(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 26.0,
                                    color: _myNumberState == "Correct"
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  children: [
                                    TextSpan(
                                        text: _myNumberState == "Correct"
                                            ? "Congratulations!!\n"
                                            : "I am sorry!!,\n"),
                                    TextSpan(
                                        text: _myNumberState == "Correct"
                                            ? "You won!"
                                            : "You lost!",
                                        style: TextStyle(fontSize: 20.0)),
                                  ])),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: _myNumberState == "Correct"
                              ? widget._gameMod == "Online with cash"
                                  ? RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          children: [
                                            TextSpan(text: "(Your money "),
                                            TextSpan(
                                                text:
                                                    "<Rs ${widget._amount ~/ 1.5}> ",
                                                style: TextStyle(
                                                    color: Color(0xff1C2826),
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            TextSpan(
                                                text:
                                                    "will be transferred to your phone within 24 hours from now)")
                                          ]))
                                  : RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          children: [
                                            TextSpan(text: "(Your "),
                                            TextSpan(
                                                text:
                                                    "${(widget._amount - 20 / 100 * widget._amount).toInt()} coins ",
                                                style: TextStyle(
                                                    color: Color(0xff1C2826),
                                                    fontWeight:
                                                        FontWeight.w700)),
                                            TextSpan(
                                                text:
                                                    "has been transferred to your account)")
                                          ]))
                              : Text(
                                  "Better luck next time.",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: 50.0,
                        ),
                        StickyButton("Exit", "", () async {
                          _interstitialAd.load();
                          if (await _interstitialAd.isLoaded) {
                            _interstitialAd.show();
                          }
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
      maxHeight: 320.0,
      minHeight: 130.0,
      panel: _mySectionOpened(),
      collapsed: _mySectionClosed(),
      body: Container(
        color: Color(0xff1fa9cc),
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 20,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _opponentSection(),
                Expanded(child: _numberSection()),
                SizedBox(
                  height: _height,
                ),
              ],
            ),
          ),
        ),
      ),
      onPanelOpened: () {
        setState(() {
          _height = 330.0;
        });
      },
      onPanelClosed: () {
        setState(() {
          _height = 100.0;
        });
      },
    );
  }

  Widget _mySectionClosed() {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Icon(Icons.arrow_drop_up, color: Colors.grey),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Text(
                    "Your number is: ",
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Color(0xff1C2826),
                        fontWeight: FontWeight.w700),
                  ),
                  _showCircularProgressBar
                      ? Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : Text(
                          _myNumberState != null ? _myNumberState : "",
                          style: TextStyle(
                              fontSize: 26.0,
                              color: _myNumberState == "Correct"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w700),
                        ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.exit_to_app, color: Colors.black),
                      onPressed: () {}),
                ],
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Expanded(flex: 2, child: _numberInputSection()),
              SizedBox(
                width: 10.0,
              ),
              Expanded(child: _guessBtnSection()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _opponentSection() {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  _isOpponentWaiting
                      ? Row(
                          children: <Widget>[
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                            SizedBox(
                              width: 5.0,
                            ),
                            Text(
                              "Waiting..",
                              style: TextStyle(
                                  fontSize: 24.0,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        )
                      : Text(
                          "$_opponentNumberState",
                          style: TextStyle(
                              fontSize: 24.0,
                              color: _opponentNumberState == "Correct"
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.w700),
                        ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ClipOval(
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      child: Image.asset("images/avatars/$_profileNum.png",
                          fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _opponentName,
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color(0xff1C2826),
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 5.0),
                        _userPointSection("opponent"),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userPointSection(var _result) {
    final _points = Provider.of<Points>(context);
    print(_points);
    return Container(
      decoration: BoxDecoration(
          color: Color(0xff493BAA),
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
                color: Colors.white.withOpacity(0.2),
                offset: Offset(0.0, 4.0),
                blurRadius: 20.0)
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                "Coins",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SvgPicture.asset("images/coins.svg"),
              SizedBox(
                height: 5.0,
              ),
              Text(
                _result == "me" ? _points.coins.toString() : _opponentCoins,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Gems",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SvgPicture.asset("images/gems.svg"),
              SizedBox(
                height: 5.0,
              ),
              Text(
                _result == "me" ? _points.gems.toString() : _opponentGems,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Cash",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10.0,
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              SvgPicture.asset("images/cash.svg"),
              SizedBox(
                height: 5.0,
              ),
              Text(
                _result == "me" ? "Rs ${_points.cash}" : "Rs $_opponentCash",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numberSection() {
    return Stack(
      children: <Widget>[
        Center(
          child: Stack(
            children: <Widget>[
              SvgPicture.asset("images/game_page_main.svg"),
              Positioned.fill(
                child: Center(
                  child: Text(
                    _myNumberState == "Correct" ||
                            _opponentNumberState == "Correct"
                        ? "$_theNumber"
                        : "####",
                    style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        _height == 100
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  AdmobBanner(
                    adUnitId: "ca-app-pub-4056821571384483/8381836879",
                    adSize: AdmobBannerSize.BANNER,
                  ),
                ],
              )
            : Container(),
      ],
    );
  }

  Widget _mySectionOpened() {
    final _user = Provider.of<User>(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20.0)),
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      "Your number is: ",
                      style: TextStyle(
                          fontSize: 14.0,
                          color: Color(0xff1C2826),
                          fontWeight: FontWeight.w700),
                    ),
                    _showCircularProgressBar
                        ? Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : Text(
                            _myNumberState != null ? _myNumberState : "",
                            style: TextStyle(
                                fontSize: 26.0,
                                color: _myNumberState == "Correct"
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.w700),
                          ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _numberInputSection(),
            ),
            SizedBox(
              height: 5.0,
            ),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: _guessBtnSection()),
            SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipOval(
                  child: Container(
                    width: 50.0,
                    height: 50.0,
                    child: Image.asset(
                        "images/avatars/${_user.profileImgNum}.png",
                        fit: BoxFit.cover),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _user.userName,
                        style: TextStyle(
                            fontSize: 16.0,
                            color: Color(0xff1C2826),
                            fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 5.0),
                      _userPointSection("me"),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _guessBtnSection() {
    final _user = Provider.of<User>(context);
    final _achievement = Provider.of<Achievements>(context);
    final _points = Provider.of<Points>(context);
    return FlatButton(
      onPressed: () {
        if (_mySectionIsEnable) {
          if (_myNumController.text != "") {
            setState(() {
              _showCircularProgressBar = true;
            });
            Timer(Duration(seconds: 3), () {
              _isMyNumberCorrect(_user, _achievement, _points);
              setState(() {
                _showCircularProgressBar = false;
              });
            });
          }
        }
      },
      color: Color(0xff6C63FF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
      child: Container(
        height: 20.0,
        child: Center(
          child: Text(
            "Guess",
            style: TextStyle(color: Colors.white, fontSize: 12.0),
          ),
        ),
      ),
    );
  }

  Widget _numberInputSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(50.0),
      ),
      child: TextFormField(
        enabled: !_isOpponentWaiting && _mySectionIsEnable,
        onTap: () {},
        keyboardType: TextInputType.number,
        controller: _myNumController,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
            border: InputBorder.none,
            hintText: "Number"),
      ),
    );
  }
}
