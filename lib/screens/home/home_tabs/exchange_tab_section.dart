import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/screens/widgets/appBar.dart';
import 'package:iprecious/screens/widgets/drawer.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:provider/provider.dart';
import 'package:admob_flutter/admob_flutter.dart';

class ExchangeTabSection extends StatefulWidget {
  @override
  _ExchangeTabSectionState createState() => _ExchangeTabSectionState();
  final AudioPlayer _player;
  ExchangeTabSection(this._player);
}

class _ExchangeTabSectionState extends State<ExchangeTabSection> {
  AdmobInterstitial _interstitialAd;
  @override
  void initState() {
    super.initState();
    _interstitialAd = AdmobInterstitial(
        adUnitId: "ca-app-pub-4056821571384483/9120203477",
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.closed) {
            _interstitialAd.load();
          }
        });
    _interstitialAd.load();
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentSelectedCoins;
  int _currentSelectedCash;

  Future<void> _showAlertDialog(final _user, final _points) {
    return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Center(
                child: Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(
                        top: 30.0, bottom: 30.0, left: 30.0),
                    width: MediaQuery.of(context).size.width - 100,
                    height: 400.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Are you sure you want to exchange $_currentSelectedCoins coins to get Rs $_currentSelectedCash?",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "REMEMBER you will receive your cash within 24 hours from now",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        StickyButton("OK, Exchange Now", "", () async {
                          if (_currentSelectedCoins < _points.coins) {
                            await DatabaseProvider(uid: _user.uid)
                                .updateUserPoints(
                              coins: _points.coins - _currentSelectedCoins,
                              cash: _points.cash,
                              gems: _points.gems,
                            );

                            await DatabaseProvider(uid: _user.uid)
                                .exchangeCoinsWithCash(
                                    _currentSelectedCoins,
                                    _currentSelectedCash,
                                    _user.userName,
                                    _user.userNcell,
                                    DateTime.now().toString());
                            Navigator.pop(context);
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "You will recieve cash within 24 hours from now!")));
                          } else {
                            Navigator.pop(context);
                            _scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text("You don't have enough coins!")));
                          }
                        }),
                        SizedBox(
                          height: 10.0,
                        ),
                        StickyButton("Cancel", "", () {
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);

    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawer(),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffFF8000), Colors.white])),
        child: Column(
          children: <Widget>[
            MyAppBar(widget._player, "Exchange", _user, () {
              _scaffoldKey.currentState.openDrawer();
            }),
            Expanded(
              child: Stack(
                children: <Widget>[
                  _exchangeSection(),
                  Positioned(
                    bottom: 0.0,
                    child: Center(
                      child: AdmobBanner(
                        adUnitId: "ca-app-pub-4056821571384483/8381836879",
                        adSize: AdmobBannerSize.FULL_BANNER,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exchangeSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 3 / 6),
        children: <Widget>[
          _exchangeItem(1100, 10),
          _exchangeItem(2100, 20),
          _exchangeItem(5100, 50),
          _exchangeItem(2100, 200),
          SizedBox(),
        ],
      ),
    );
  }

  Widget _exchangeItem(int _exchange, int _toGet) {
    final _user = Provider.of<User>(context);
    final _points = Provider.of<Points>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0.0, 5.0),
                  blurRadius: 15.0)
            ]),
        child: Stack(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SvgPicture.asset("images/arrow.svg"),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "Exchange: ",
                    style: TextStyle(fontSize: 18.0, color: Color(0xff722FA4)),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: <Widget>[
                        SvgPicture.asset("images/coins.svg"),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          "$_exchange",
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Color(0xff722FA4),
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    "To get: ",
                    style: TextStyle(fontSize: 18.0, color: Color(0xff722FA4)),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Rs $_toGet",
                      style: TextStyle(
                          fontSize: 22.0,
                          color: Color(0xff722FA4),
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 20.0,
                right: 0.0,
                child: StickyButton("Get Money", "", () async {
                  if (await _interstitialAd.isLoaded) {
                    _interstitialAd.show();
                  }
                  setState(() {
                    _currentSelectedCoins = _exchange;
                    _currentSelectedCash = _toGet;
                  });
                  _showAlertDialog(_user, _points);
                }))
          ],
        ),
      ),
    );
  }
}
