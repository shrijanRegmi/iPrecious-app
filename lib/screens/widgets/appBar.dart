import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/services/music/music.dart';

class MyAppBar extends StatefulWidget {
  final _title;
  final _function;
  final User _user;
  final AudioPlayer _player;
  MyAppBar(this._player, this._title, this._user, this._function) : super();

  @override
  _MyAppBarState createState() => _MyAppBarState();
}

class _MyAppBarState extends State<MyAppBar> {
  bool _isPlaying;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget._player.state != AudioPlayerState.PAUSED ? true : false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                  onTap: widget._function,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        color: Colors.transparent,
                        child: SvgPicture.asset("images/menu.svg")),
                  )),
              SizedBox(
                width: 20.0,
              ),
              Text(
                widget._title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              SizedBox(
                width: 3.0,
              ),
              Text("${widget._user.playLife}",
                  style: TextStyle(color: Colors.white)),
              Container(
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: IconButton(
                          icon: Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPlaying = false;
                            });
                            Music().pauseMusic(widget._player);
                          }),
                    ),
                    !_isPlaying
                        ? IconButton(
                            icon: Icon(
                              Icons.not_interested,
                              color: Colors.red,
                              size: 40.0,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPlaying = true;
                              });
                              Music().resumeMusic(widget._player);
                            })
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
