import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iprecious/screens/authentication/create_account_screen.dart';
import 'package:iprecious/screens/widgets/authField.dart';
import 'package:iprecious/services/authentication/auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
  final _auth = AuthProvider();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  final _loginKey = GlobalKey<FormState>();

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
        body: Container(
          child: ListView(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 20,
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
                    _imgSection(),
                    _inputSection(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _bottomTextSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _imgSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: <Widget>[
            Text("Welcome Back!",
                style: TextStyle(
                  color: Color(0xff131010),
                  fontSize: 26.0,
                  fontWeight: FontWeight.w800,
                )),
            SizedBox(
              height: 10.0,
            ),
            Expanded(child: SvgPicture.asset("images/login_main.svg")),
          ],
        ),
      ),
    );
  }

  Widget _inputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
          child: Form(
        key: _loginKey,
        child: Column(
          children: <Widget>[
            AuthField(Icons.mail, "Email", _emailController, Icons.done,
                TextInputType.emailAddress),
            SizedBox(
              height: 30.0,
            ),
            AuthField(Icons.lock, "Password", _passwordController,
                Icons.remove_red_eye, TextInputType.text),
            SizedBox(
              height: 30.0,
            ),
            FlatButton(
              onPressed: () async {
                FocusScope.of(context).unfocus();
                if (await _interstitialAd.isLoaded) {
                  _interstitialAd.show();
                }
                if (_loginKey.currentState.validate()) {
                  _showCircularProgressBar(true);
                  var _result = await _auth.loginUser(
                      _emailController.text.trim(),
                      _passwordController.text.trim());
                  if (_result != null) {
                    _showCircularProgressBar(false);
                    Navigator.pop(context);
                  } else {
                    _showCircularProgressBar(false);
                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text("Login failed. Please try again")));
                  }
                }
              },
              color: Color(0xff6C63FF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
              child: Container(
                height: 50.0,
                child: Center(
                  child: Text(
                    "Login",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  Widget _bottomTextSection() {
    return GestureDetector(
      onTap: () async {
        if (await _interstitialAd.isLoaded) {
          _interstitialAd.show();
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CreateAccountScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Don't have an account?",
              style: TextStyle(color: Colors.grey, fontSize: 12.0),
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(
              "Create here",
              style: TextStyle(
                  color: Color(0xff131010),
                  fontSize: 12.0,
                  fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
