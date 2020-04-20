import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:iprecious/models/database_models/active_user.dart';
import 'package:iprecious/models/database_models/msg.dart';
import 'package:iprecious/models/database_models/user.dart';
import 'package:iprecious/services/database/database.dart';
import 'package:iprecious/services/database/message.dart';
import 'package:provider/provider.dart';

import '../chats_screen.dart';

class MessageTabSection extends StatefulWidget {
  @override
  _MessageTabSectionState createState() => _MessageTabSectionState();
}

class _MessageTabSectionState extends State<MessageTabSection> {
  final _scffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    return MultiProvider(
        providers: [
          StreamProvider<List<ActiveUser>>.value(
              value: DatabaseProvider(uid: _user.uid).activeUser),
          StreamProvider<List<User>>.value(
            value: MessageProvider(uid: _user.uid).usersList,
          ),
          StreamProvider<List<Message>>.value(
            value: MessageProvider(uid: _user.uid).squadList,
          )
        ],
        child: Scaffold(
          key: _scffoldKey,
          body: Stack(
            children: <Widget>[
              Container(
                  color: Color(0xff5317e1),
                  child: ListView(
                    children: <Widget>[
                      StreamBuilder(
                        stream: DatabaseProvider(uid: _user.uid).userDetail,
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return Column(
                              children: <Widget>[
                                _appbarImgSection(snapshot.data),
                                SizedBox(
                                  height: 30.0,
                                ),
                                _textSection(snapshot.data),
                                SizedBox(
                                  height: 30.0,
                                ),
                                ActiveUsers(),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minHeight: 30.0,
                                      maxHeight: double.infinity),
                                ),
                                RecentMessages(),
                              ],
                            );
                          } else if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                          }
                          return Center(child: CircularProgressIndicator());
                        },
                      )
                    ],
                  )),
              Positioned(
                bottom: 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    AdmobBanner(
                      adUnitId: "ca-app-pub-4056821571384483/8381836879",
                      adSize: AdmobBannerSize.FULL_BANNER,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _appbarImgSection(var ds) {
    final _user = Provider.of<User>(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _scffoldKey.currentState.openDrawer();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  width: 34.0,
                  height: 34.0,
                  child: Image.asset(
                      "images/avatars/${_user.profileImgNum}.png",
                      fit: BoxFit.cover),
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                "Play Lives left: ${_user.playLife}",
                style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: "Mont",
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textSection(var user) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Have a great day,",
            style: TextStyle(
                fontSize: 28.0,
                fontFamily: "Mont",
                fontWeight: FontWeight.w600,
                color: Colors.white),
          ),
          Text("${user.userName}.",
              style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: "Mont",
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class ActiveUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    final _activeUsersList = Provider.of<List<ActiveUser>>(context) ?? [];
    print(_activeUsersList.length);
    return Container(
      height: 120.0,
      child: _activeUsersList.length <= 1
          ? Center(
              child: Text("No active users",
                  style: TextStyle(
                      color: Colors.white, fontStyle: FontStyle.italic)))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _activeUsersList.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width / 2 - 70),
                    child: _getUsersListItem(
                        _activeUsersList[index].activeUser != _user.uid
                            ? _activeUsersList[index]
                            : null,
                        context),
                  );
                } else {
                  return _getUsersListItem(
                      _activeUsersList[index].activeUser != _user.uid
                          ? _activeUsersList[index]
                          : null,
                      context);
                }
              },
            ),
    );
  }

  Widget _getUsersListItem(var data, BuildContext context) {
    final _user = Provider.of<User>(context);
    if (data != null) {
      return StreamBuilder(
        stream: DatabaseProvider(uid: data.activeUser).userDetail,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatsScreen(snapshot.data)));
                if (snapshot.data.seenState != null) {
                  await MessageProvider().updateSeenStateMessage(
                    _user.uid.hashCode > snapshot.data.uid.hashCode
                        ? "${_user.uid}${snapshot.data.uid}"
                        : "${snapshot.data.uid}${_user.uid}",
                    true,
                  );
                }

                await MessageProvider().updateSeenStateChat(
                    _user.uid.hashCode > snapshot.data.uid.hashCode
                        ? "${_user.uid}${snapshot.data.uid}"
                        : "${snapshot.data.uid}${_user.uid}",
                    true);
              },
              child: Stack(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: ClipOval(
                            child: Container(
                          width: 90.0,
                          height: 90.0,
                          child: Image.asset(
                            "images/avatars/${snapshot.data.profileImgNum}.png",
                          ),
                        )),
                      ),
                      Text(
                        snapshot.data.userName.contains(" ")
                            ? snapshot.data.userName.substring(
                                0, snapshot.data.userName.indexOf(" "))
                            : snapshot.data.userName,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 10.0,
                    top: 10.0,
                    child: ClipOval(
                      child: Container(
                        width: 13.0,
                        height: 13.0,
                        color: Colors.green,
                      ),
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Center(child: Container());
        },
      );
    } else {
      return Container();
    }
  }
}

class RecentMessages extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final _user = Provider.of<User>(context);
    final _squadList = Provider.of<List<Message>>(context) ?? [];
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)),
          ),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  bottom: 10.0,
                  top: 30.0,
                ),
                child: Container(
                  child: Text(
                    "Squad",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontFamily: "Mont",
                        fontWeight: FontWeight.w600,
                        color: Colors.black),
                  ),
                ),
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: ListView.builder(
                    itemCount: _squadList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      if (_squadList[index] == _squadList.last) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 70.0),
                          child: _getMessageListItem(
                              context,
                              _squadList[index].sender == _user.uid ||
                                      _squadList[index].receiver == _user.uid
                                  ? _squadList[index]
                                  : null),
                        );
                      } else {
                        return _getMessageListItem(
                            context,
                            _squadList[index].sender == _user.uid ||
                                    _squadList[index].receiver == _user.uid
                                ? _squadList[index]
                                : null);
                      }
                    },
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getMessageListItem(BuildContext context, var data) {
    final _user = Provider.of<User>(context);
    if (data != null) {
      return StreamBuilder(
        stream: DatabaseProvider(
                uid: data.sender == _user.uid ? data.receiver : data.sender)
            .userDetail,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () async {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatsScreen(snapshot.data)));

                if (data.receiver == _user.uid) {
                  await MessageProvider().sendSquad(
                    uniqueId: _user.uid.hashCode > snapshot.data.uid.hashCode
                        ? "${_user.uid}${snapshot.data.uid}"
                        : "${snapshot.data.uid}${_user.uid}",
                    msg: data.msg,
                    senderId: data.sender,
                    receiverId: data.receiver,
                    date: data.date,
                    seenState: true,
                  );

                  await MessageProvider().updateSeenStateMessage(
                      _user.uid.hashCode > snapshot.data.uid.hashCode
                          ? "${_user.uid}${snapshot.data.uid}"
                          : "${snapshot.data.uid}${_user.uid}",
                      true);
                  await MessageProvider().updateSeenStateChat(
                      _user.uid.hashCode > snapshot.data.uid.hashCode
                          ? "${_user.uid}${snapshot.data.uid}"
                          : "${snapshot.data.uid}${_user.uid}",
                      true);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 10.0),
                child: Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Container(
                              height: 50.0,
                              width: 50.0,
                              child: Image.asset(
                                "images/avatars/${snapshot.data.profileImgNum}.png",
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                snapshot.data.userName,
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: data.receiver == _user.uid &&
                                            !data.seenState
                                        ? 10.0
                                        : 0.0),
                                child: data.receiver == _user.uid &&
                                        !data.seenState
                                    ? Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.0, vertical: 4.0),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3.0),
                                              color: Colors.deepOrange,
                                            ),
                                            child: Center(
                                              child: Text(
                                                "New",
                                                style: TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            data.msg.toString().length > 20
                                                ? "${data.msg.toString().substring(0, 20)}..."
                                                : data.msg,
                                            style: TextStyle(
                                                fontSize: 12.0,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        data.msg.toString().length > 20
                                            ? "${data.msg.toString().substring(0, 20)}..."
                                            : data.msg,
                                        style: TextStyle(
                                            fontSize: 12.0, color: Colors.grey),
                                      ),
                              )
                            ],
                          )
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Text(
                            "On ${(data.date).toString().substring(0, 10)}",
                            style: TextStyle(
                                fontSize: 9.0,
                                fontFamily: "Mont",
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          ),
                          Text(
                            "At ${(data.date).toString().substring(11, 16)}",
                            style: TextStyle(
                                fontSize: 9.0,
                                fontFamily: "Mont",
                                fontWeight: FontWeight.w400,
                                color: Colors.grey),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return SizedBox();
        },
      );
    } else {
      return Container();
    }
  }
}
