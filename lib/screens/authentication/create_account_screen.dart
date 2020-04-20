import 'dart:async';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:iprecious/models/list_models/avatars.dart';
import 'package:iprecious/screens/widgets/authField.dart';
import 'package:iprecious/screens/widgets/select_avatar.dart';
import 'package:iprecious/services/authentication/auth.dart';

class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  AdmobInterstitial _interstitialAd;

  @override
  void initState() {
    super.initState();
    c = PageController();
    avatars.shuffle();
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

  final _auth = AuthProvider();

  List<String> _simList = ["Ncell", "Ntc", "Both"];
  String _selectedSim = "Ncell";

  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _ncellController = TextEditingController();
  TextEditingController _ntcController = TextEditingController();
  TextEditingController _scodeController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _inputKey = GlobalKey<FormState>();
  final _phoneKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isCreatedSuccesfully = false;
  bool _isProfileImgSelected = false;

  int _currentPage = 0;

  ScrollController c;
  String _profileImgNum;

  Future<void> _showCircularProgressBar(bool show) async {
    if (show) {
      return showDialog(
          context: context,
          child: Center(
            child: CircularProgressIndicator(),
          ));
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: _isCreatedSuccesfully
            ? _accountCreatedSuccessfully()
            : _creatingAccount(),
      ),
    );
  }

  Widget _creatingAccount() {
    return Container(
      child: Stack(
        children: <Widget>[
          ListView(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 20.0,
                child: Column(
                  children: <Widget>[
                    _appNameSection(),
                    SizedBox(
                      height: 2.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        AdmobBanner(
                          adUnitId: "ca-app-pub-4056821571384483/8381836879",
                          adSize: AdmobBannerSize.BANNER,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    _topTextSection(),
                    Expanded(
                      flex: 2,
                      child: PageView(
                        controller: c,
                        onPageChanged: (value) {
                          setState(() {
                            _currentPage = value;
                          });
                        },
                        children: <Widget>[
                          !_isProfileImgSelected
                              ? _characterSection()
                              : _showCharacter(),
                          _inputSection(),
                          _phoneSection(),
                        ],
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: _currentPage == 2
                            ? _createAccountBtnSection()
                            : _nextBtnSection()),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nextBtnSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: FlatButton(
          onPressed: () {
            if (_isProfileImgSelected) {
              switch (_currentPage) {
                case 0:
                  c.animateTo(MediaQuery.of(context).size.width,
                      duration: Duration(milliseconds: 800),
                      curve: Curves.fastOutSlowIn);
                  break;
                case 1:
                  if (_inputKey.currentState.validate()) {
                    c.animateTo(MediaQuery.of(context).size.width * 2,
                        duration: Duration(milliseconds: 800),
                        curve: Curves.fastOutSlowIn);
                  }
                  break;
              }
            } else {
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(content: Text("Please choose a character")),
              );
            }
          },
          color: Color(0xff6C63FF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          child: Container(
            height: 50.0,
            child: Center(
              child: Text(
                "Next",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _createAccountBtnSection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: FlatButton(
          onPressed: () async {
            FocusScope.of(context).unfocus();
            if (await _interstitialAd.isLoaded) {
              _interstitialAd.show();
            }
            if (_phoneKey.currentState.validate()) {
              _showCircularProgressBar(true);
              var _result = await _auth.createUserAccount(
                  _nameController.text.trim(),
                  _emailController.text.trim(),
                  _profileImgNum,
                  _ncellController.text.trim(),
                  _ntcController.text.trim(),
                  _scodeController.text.trim(),
                  _passwordController.text.trim());

              if (_result != null) {
                _showCircularProgressBar(false);
                Navigator.pop(context);
              } else {
                _showCircularProgressBar(false);
              }
            }
          },
          color: Color(0xff6C63FF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50.0)),
          child: Container(
            height: 50.0,
            child: Center(
              child: Text(
                "Create Account",
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _characterSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              Text(
                "Choose a character:",
                style: TextStyle(
                  color: Color(0xff564FCC),
                  fontSize: 18.0,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.start,
              ),
              Text(
                "<Swipe to see more>",
                style: TextStyle(
                  color: Color(0xff564FCC),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20.0,
        ),
        Container(
          height: 240.0,
          child: SelectAvatar((int) {
            setState(() {
              _profileImgNum = int;
              _isProfileImgSelected = true;
            });
          }),
        ),
      ],
    );
  }

  Widget _showCharacter() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Stack(
        children: <Widget>[
          Container(
            child: Image.asset(
              "images/avatars/$_profileImgNum.png",
            ),
          ),
          Positioned(
            right: 0.0,
            child: IconButton(
              icon: Icon(Icons.cancel, size: 40.0),
              onPressed: () {
                setState(() {
                  _isProfileImgSelected = false;
                });
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _appNameSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: <Widget>[
          Text(
            "iPrecious",
            style: TextStyle(
                color: Color(0xff564FCC),
                fontSize: 16.0,
                fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _topTextSection() {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            "Create Account",
            style: TextStyle(
              color: Color(0xff131010),
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          Text("Fill all the fields to create an account",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.0,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _inputSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xff564FCC)),
              onPressed: () {
                c.animateTo(-MediaQuery.of(context).size.width + 200,
                    duration: Duration(milliseconds: 800),
                    curve: Curves.fastOutSlowIn);
              },
            ),
          ],
        ),
        SizedBox(
          height: 10.0,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _inputKey,
            child: Column(
              children: <Widget>[
                AuthField(Icons.edit, "Name", _nameController, Icons.done,
                    TextInputType.text),
                SizedBox(
                  height: 30.0,
                ),
                AuthField(Icons.mail, "Email", _emailController, Icons.done,
                    TextInputType.emailAddress),
                SizedBox(
                  height: 30.0,
                ),
                AuthField(Icons.lock, "Password", _passwordController,
                    Icons.remove_red_eye, TextInputType.text),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _phoneSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios, color: Color(0xff564FCC)),
              onPressed: () {
                c.animateTo(MediaQuery.of(context).size.width,
                    duration: Duration(milliseconds: 800),
                    curve: Curves.fastOutSlowIn);
              },
            ),
          ],
        ),
        SizedBox(
          height: 20.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _phoneKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Select Sim",
                          style: TextStyle(
                            color: Color(0xff564FCC),
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        DropdownButton(
                          items: _simList.map((String dropdownItem) {
                            return DropdownMenuItem(
                              value: dropdownItem,
                              child: Text(
                                dropdownItem,
                                style: TextStyle(color: Color(0xff564FCC)),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSim = value;
                            });
                          },
                          value: _selectedSim,
                        ),
                      ],
                    ),
                  ],
                ),
                _selectedSim == "Ncell"
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: AuthField(Icons.phone, "Ncell", _ncellController,
                            Icons.done, TextInputType.phone),
                      )
                    : _selectedSim == "Ntc"
                        ? Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: AuthField(
                                    Icons.phone,
                                    "Ntc",
                                    _ntcController,
                                    Icons.done,
                                    TextInputType.phone),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: AuthField(
                                    Icons.phone_android,
                                    "Security code of Ntc",
                                    _scodeController,
                                    Icons.done,
                                    TextInputType.phone),
                              ),
                              Container(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "To find security code of Ntc please send an sms 'SCODE' to 1415",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: AuthField(
                                    Icons.phone,
                                    "Ncell",
                                    _ncellController,
                                    Icons.done,
                                    TextInputType.phone),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: AuthField(
                                    Icons.phone,
                                    "Ntc",
                                    _ntcController,
                                    Icons.done,
                                    TextInputType.phone),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20.0),
                                child: AuthField(
                                    Icons.phone_android,
                                    "Security code of Ntc",
                                    _scodeController,
                                    Icons.done,
                                    TextInputType.phone),
                              ),
                            ],
                          )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _accountCreatedSuccessfully() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 100.0,
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            "Succesfully\nCreated Account",
            style: TextStyle(
              color: Colors.green,
              fontSize: 26.0,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
