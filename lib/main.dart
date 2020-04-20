import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:iprecious/services/authentication/auth.dart';
import 'package:iprecious/wrapper.dart';
import 'package:provider/provider.dart';

import 'models/database_models/user.dart';

void main() {
  Admob.initialize("ca-app-pub-4056821571384483~7260326899");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthProvider().user,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Material(
          child: Wrapper(),
        ),
      ),
    );
  }
}
