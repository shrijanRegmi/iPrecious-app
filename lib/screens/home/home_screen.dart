import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:iprecious/services/music/music.dart';
import 'package:provider/provider.dart';
import 'home_tabs/activity_tab_section.dart';
import 'home_tabs/buy_tab_section.dart';
import 'home_tabs/exchange_tab_section.dart';
import 'home_tabs/home_tab_section.dart';
import 'home_tabs/message_tab_section.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 5);
    _initPlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final _user = Provider.of<User>(context);
    _onlineStatus(true, _user);
    _handleAppLifecycleState(_user);
  }

  _initPlayer() async {
    AudioPlayer _player = await Music().playMusic();
    setState(() {
      _audioPlayer = _player;
    });
  }

  _handleAppLifecycleState(final _user) {
    SystemChannels.lifecycle.setMessageHandler((msg) {
      print('SystemChannels> $msg');
      switch (msg) {
        case "AppLifecycleState.paused":
          return null;
          break;
        case "AppLifecycleState.inactive":
          if (_audioPlayer.state == AudioPlayerState.PLAYING) {
            Music().pauseMusic(_audioPlayer);
          }
          return _onlineStatus(false, _user);
          break;
        case "AppLifecycleState.resumed":
          if (_audioPlayer.state == AudioPlayerState.PAUSED) {
            Music().resumeMusic(_audioPlayer);
          }
          return _onlineStatus(true, _user);
          break;
        default:
          return null;
      }
    });
  }

  _onlineStatus(var _result, final _user) async {
    if (_result) {
      await DatabaseProvider(uid: _user.uid).sendActiveUsers();
    } else {
      await DatabaseProvider(uid: _user.uid).deleteActiveUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return StreamProvider<Points>.value(
      value: DatabaseProvider(uid: _user.uid).points,
      child: StreamProvider<User>.value(
        value: DatabaseProvider(uid: _user.uid).userDetail,
        child: StreamProvider<Achievements>.value(
          value: DatabaseProvider(uid: _user.uid).achievement,
          child: SafeArea(
            child: Scaffold(
              body: Container(
                child: _bodySection(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodySection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[_tabBarViewSection(), _tabBarSection()],
    );
  }

  Widget _tabBarViewSection() {
    final _user = Provider.of<User>(context);
    return Expanded(
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          HomeTabSection(_audioPlayer, _user.uid),
          ActivityTabSection(_audioPlayer, _user.uid),
          ExchangeTabSection(_audioPlayer),
          BuyTabSection(_audioPlayer),
          MessageTabSection(),
        ],
      ),
    );
  }

  Widget _tabBarSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            color: Color(0xffF6C1C1).withOpacity(0.5),
            offset: Offset(0.0, -5.0),
            blurRadius: 10.0)
      ]),
      child: TabBar(
        indicatorColor: Color(0xffFF7777),
        controller: _tabController,
        tabs: <Widget>[
          Tab(
            icon: SvgPicture.asset(
              "images/home_tab.svg",
            ),
          ),
          Tab(
            icon: SvgPicture.asset("images/activity_tab.svg"),
          ),
          Tab(
            icon: SvgPicture.asset("images/exchange_tab.svg"),
          ),
          Tab(
            icon: SvgPicture.asset("images/buy_tab.svg"),
          ),
          Tab(
            icon: SvgPicture.asset("images/message_tab.svg"),
          ),
        ],
      ),
    );
  }
}
