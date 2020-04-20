import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intent/action.dart' as android_action;
import 'package:intent/intent.dart' as android_intent;
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/screens/widgets/appBar.dart';
import 'package:iprecious/screens/widgets/drawer.dart';
import 'package:iprecious/screens/widgets/stickyButton.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:admob_flutter/admob_flutter.dart';

class BuyTabSection extends StatefulWidget {
  @override
  _BuyTabSectionState createState() => _BuyTabSectionState();
  final AudioPlayer _player;
  BuyTabSection(this._player);
}

class _BuyTabSectionState extends State<BuyTabSection> {
  AdmobInterstitial _interstitialAd;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

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

  List<String> _simList = ["Ncell", "Ntc"];
  String _currentSelectedSim = "Ncell";

  int _currentSelectedCash;
  int _currentSelectedCoins;
  bool _showProgressBar = false;

  _transferMoney(final _user) async {
    PermissionStatus _permissionStatus =
        await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
    if (_permissionStatus != PermissionStatus.granted) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Please allow permission first!"),
        action: SnackBarAction(
            label: "Allow now",
            onPressed: () async {
              var _result = await PermissionHandler()
                  .requestPermissions([PermissionGroup.phone]);
              if (_result.values.contains(PermissionStatus.granted)) {
                android_intent.Intent()
                  ..setAction(android_action.Action.ACTION_CALL)
                  ..setData(Uri(
                      scheme: "tel",
                      path: _currentSelectedSim == "Ncell"
                          ? "*17122*9808950454*$_currentSelectedCash#"
                          : "*422*${_user.ntcScode}*9841080946*$_currentSelectedCash#"))
                  ..startActivity().catchError((e) => print(e));
                await DatabaseProvider(uid: _user.uid).buyCoins(
                    _currentSelectedCoins,
                    _currentSelectedCash,
                    _user.userName,
                    _user.userNcell,
                    DateTime.now().toString());
              }
            }),
      ));
    } else {
      android_intent.Intent()
        ..setAction(android_action.Action.ACTION_CALL)
        ..setData(Uri(
            scheme: "tel",
            path: _currentSelectedSim == "Ncell"
                ? "*17122*9808950454*$_currentSelectedCash#"
                : "*422*${_user.ntcScode}*9841080946*$_currentSelectedCash#"))
        ..startActivity().catchError((e) => print(e));
      await DatabaseProvider(uid: _user.uid).buyCoins(
          _currentSelectedCoins,
          _currentSelectedCash,
          _user.userName,
          _user.userNcell,
          DateTime.now().toString());
    }
  }

  Future<void> _showAlertDialog(final _user) {
    print(_user.userName);
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
                    height: 500.0,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _showProgressBar
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(),
                        SizedBox(
                          height: 5.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  "Are you sure you want to buy coins?",
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
                                  "(You are going to use Rs $_currentSelectedCash from your balance)\nA dialog will popup asking 0 or 1, if you want to buy coins then please press 1. REMEMBER you will receive coins within 24 hours from now",
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
                          height: 50.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Text(
                                  "Select sim",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                DropdownButton(
                                  value: _currentSelectedSim,
                                  items: _simList
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text("$e")))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _currentSelectedSim = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        StickyButton("OK, Buy Now", "", () async {
                          _transferMoney(_user);
                          Navigator.pop(context);
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
                colors: [Color(0xffFF4051), Colors.white])),
        child: Column(
          children: <Widget>[
            MyAppBar(widget._player, "Buy", _user, () {
              _scaffoldKey.currentState.openDrawer();
            }),
            Expanded(
              child: Stack(
                children: <Widget>[
                  _buySection(),
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

  Widget _buySection() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 3 / 6),
        children: <Widget>[
          _buyItem(1000, 10),
          _buyItem(2000, 20),
          _buyItem(5000, 50),
          _buyItem(20000, 200),
          SizedBox(),
        ],
      ),
    );
  }

  Widget _buyItem(int _buy, int _with) {
    final _user = Provider.of<User>(context);
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
                  SvgPicture.asset("images/buy.svg"),
                  SizedBox(
                    height: 5.0,
                  ),
                  Text(
                    "Buy: ",
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
                          "$_buy",
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
                    "With: ",
                    style: TextStyle(fontSize: 18.0, color: Color(0xff722FA4)),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      "Rs $_with",
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
                child: StickyButton("Buy Coins", "", () async {
                  if (await _interstitialAd.isLoaded) {
                    _interstitialAd.show();
                  }
                  setState(() {
                    _currentSelectedCash = _with;
                    _currentSelectedCoins = _buy;
                  });
                  _showAlertDialog(_user);
                }))
          ],
        ),
      ),
    );
  }
}
