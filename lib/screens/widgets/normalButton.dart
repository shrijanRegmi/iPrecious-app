import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final _title;
  final _function;
  MyButton(this._title, this._function) : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _function,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        height: 40.0,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xffE94AC9), Color(0xffF6C1C1)]),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  offset: Offset(0.0, 2.0),
                  blurRadius: 10.0)
            ]),
        child: Center(
          child: Text(
            _title,
            style: TextStyle(fontSize: 14.0, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
