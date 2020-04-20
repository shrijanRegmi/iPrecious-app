import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iprecious/screens/authentication/create_account_screen.dart';
import 'package:iprecious/screens/authentication/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            _appNameSection(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AdmobBanner(
                  adUnitId: "ca-app-pub-4056821571384483/8381836879",
                  adSize: AdmobBannerSize.BANNER,
                ),
              ],
            ),
            _imgSection(),
            _btnSection(),
            SizedBox(
              height: 20.0,
            ),
            AdmobBanner(
              adUnitId: "ca-app-pub-4056821571384483/8381836879",
              adSize: AdmobBannerSize.FULL_BANNER,
            ),
          ],
        ),
      ),
    ));
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
            Expanded(child: SvgPicture.asset("images/welcome_main.svg")),
            SizedBox(
              height: 20.0,
            ),
            Text("Welcome",
                style: TextStyle(
                  color: Color(0xff131010),
                  fontSize: 26.0,
                  fontWeight: FontWeight.w800,
                )),
            SizedBox(
              height: 5.0,
            ),
            Text("App allows you to play games with your phone balance",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _btnSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            child: FlatButton(
              onPressed: () async {
                if (await _interstitialAd.isLoaded) {
                  _interstitialAd.show();
                }
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()));
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
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: FlatButton(
              onPressed: () async {
                if (await _interstitialAd.isLoaded) {
                  _interstitialAd.show();
                }
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CreateAccountScreen()));
              },
              color: Color(0xffFF4051),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0)),
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
          )
        ],
      ),
    );
  }

  // Widget _socialMediaSection() {
  //   return Container(
  //     child: Column(
  //       children: <Widget>[
  //         Text("or via social media",
  //             style: TextStyle(
  //               color: Colors.grey,
  //               fontSize: 14.0,
  //             ),
  //             textAlign: TextAlign.center),
  //         SizedBox(
  //           height: 10.0,
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: <Widget>[
  //             SvgPicture.asset("images/google.svg"),
  //             SizedBox(
  //               width: 10.0,
  //             ),
  //             SvgPicture.asset("images/facebook.svg"),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }
}
