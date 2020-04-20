import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iprecious/models/database_models/points.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/services/authentication/auth.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:iprecious/services/music/music.dart';
import 'package:provider/provider.dart';

class MyDrawer extends StatelessWidget {
  final from;
  final AudioPlayer player;
  MyDrawer({this.from, this.player});
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    final _points = Provider.of<Points>(context);
    final _achievement = Provider.of<Achievements>(context);

    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              accountName: Text(_user.userName),
              accountEmail: Text(_user.userEmail),
              currentAccountPicture: ClipOval(
                child: Container(
                  width: 35.0,
                  height: 35.0,
                  child: Image.asset(
                      "images/avatars/${_user.profileImgNum}.png",
                      fit: BoxFit.cover),
                ),
              )),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: Colors.red,
            ),
            title: Text("Play Lives"),
            trailing: Text(_points != null ? "${_user.playLife}" : "0"),
          ),
          ListTile(
            leading: SvgPicture.asset("images/cash.svg"),
            title: Text("Net Cash"),
            trailing: Text(_points != null ? "${_points.cash}" : "0"),
          ),
          ListTile(
            leading: SvgPicture.asset("images/coins.svg"),
            title: Text("Coins"),
            trailing: Text(_points != null ? "${_points.coins}" : "0"),
          ),
          ListTile(
            leading: SvgPicture.asset("images/gems.svg"),
            title: Text("Gems"),
            trailing: Text(_points != null ? "${_points.gems}" : "0"),
          ),
          Divider(color: Colors.grey),
          ListTile(
            title: Text("Games won"),
            trailing:
                Text(_achievement != null ? "${_achievement.gameWon}" : "0"),
          ),
          ListTile(
            title: Text("Games Lost"),
            trailing:
                Text(_achievement != null ? "${_achievement.gameLost}" : "0"),
          ),
          from != "Message"
              ? Column(
                  children: <Widget>[
                    Divider(
                      color: Colors.grey,
                    ),
                    ListTile(
                        onTap: () async {
                          await Music().stopMusic(player);
                          await DatabaseProvider(uid: _user.uid)
                              .deleteActiveUser();
                          await AuthProvider().signOut();
                        },
                        title: Text("Log out"),
                        trailing: Icon(Icons.exit_to_app)),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
