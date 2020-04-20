import 'package:flutter/material.dart';
import 'package:iprecious/screens/authentication/welcome_screen.dart';
import 'package:iprecious/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

import 'models/database_models/user.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return WelcomeScreen();
    }
    else{
      return HomeScreen();
    }
  }
}
