import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  @override
  _AuthFieldState createState() => _AuthFieldState();

  final _leadingIcon;
  final _trailingIcon;
  final _hintText;
  final _controller;
  final _keyboardType;
  AuthField(this._leadingIcon, this._hintText, this._controller,
      this._trailingIcon, this._keyboardType)
      : super();
}

class _AuthFieldState extends State<AuthField> {
  bool _isTypingName = false;
  bool _isTypingEmail = false;
  bool _isTypingNcell = false;
  bool _isTypingNtc = false;

  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xff564FCC)))),
      child: TextFormField(
        validator: (value) {
          switch (widget._hintText) {
            case "Name":
              if (value.isEmpty) {
                return "This field cannot be empty!";
              } else if (value.length < 6) {
                return "Name must be longer than 6 characters";
              }
              break;
            case "Email":
              if (value.isEmpty) {
                return "This field cannot be empty!";
              } else if (!value.contains("@") || !value.contains(".com")) {
                return "Please enter a valid email";
              }
              break;
            case "Password":
              if (value.isEmpty) {
                return "This field cannot be empty!";
              } else if (value.length < 6) {
                return "Password must be longer than 6 characters";
              }
              break;
            case "Ncell":
              if (value.isEmpty) {
                return "This field cannot be empty!";
              } else if (value.length != 10) {
                return "Enter a valid phone number";
              }
              break;
            case "Ntc":
              if (value.isEmpty) {
                return "This field cannot be empty!";
              } else if (value.length != 10) {
                return "Enter a valid phone number";
              }
              break;
            default:
              return null;
          }
          return null;
        },
        onChanged: (value) {
          switch (widget._hintText) {
            case "Name":
              if (value.isNotEmpty && value.length > 6) {
                setState(() {
                  _isTypingName = true;
                });
              } else {
                setState(() {
                  _isTypingName = false;
                });
              }
              break;
            case "Email":
              if (value.isNotEmpty &&
                  value.contains("@") &&
                  value.contains(".com")) {
                setState(() {
                  _isTypingEmail = true;
                });
              } else {
                setState(() {
                  _isTypingEmail = false;
                });
              }
              break;
            case "Ncell":
              if (value.isNotEmpty && value.length == 10) {
                setState(() {
                  _isTypingNcell = true;
                });
              } else {
                setState(() {
                  _isTypingNcell = false;
                });
              }
              break;
            case "Ntc":
              if (value.isNotEmpty && value.length == 10) {
                setState(() {
                  _isTypingNtc = true;
                });
              } else {
                setState(() {
                  _isTypingNtc = false;
                });
              }
              break;
            default:
              return null;
          }
          return null;
        },
        keyboardType: widget._keyboardType,
        controller: widget._controller,
        obscureText:
            widget._hintText == "Password" ? !_isPasswordVisible : false,
        style: TextStyle(color: Color(0xff564FCC)),
        cursorColor: Color(0xff564FCC),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 15.0),
          hintText: widget._hintText,
          prefixIcon: Icon(
            widget._leadingIcon,
            color: Color(0xff564FCC),
          ),
          suffixIcon: widget._hintText == "Password"
              ? GestureDetector(
                  onTap: () {
                    if (!_isPasswordVisible) {
                      setState(() {
                        _isPasswordVisible = true;
                      });
                    } else {
                      setState(() {
                        _isPasswordVisible = false;
                      });
                    }
                  },
                  child: Icon(
                    widget._hintText == "Name" && _isTypingName
                        ? widget._trailingIcon
                        : widget._hintText == "Email" && _isTypingEmail
                            ? widget._trailingIcon
                            : widget._hintText == "Ncell" && _isTypingNcell
                                ? widget._trailingIcon
                                : widget._hintText == "Ntc" && _isTypingNtc
                                    ? widget._trailingIcon
                                    : widget._hintText == "Password"
                                        ? _isPasswordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off
                                        : null,
                    color: Color(0xff564FCC),
                  ),
                )
              : Icon(
                  widget._hintText == "Name" && _isTypingName
                      ? widget._trailingIcon
                      : widget._hintText == "Email" && _isTypingEmail
                          ? widget._trailingIcon
                          : widget._hintText == "Ncell" && _isTypingNcell
                              ? widget._trailingIcon
                              : widget._hintText == "Ntc" && _isTypingNtc
                                  ? widget._trailingIcon
                                  : widget._hintText == "Password"
                                      ? widget._trailingIcon
                                      : null,
                  color: Color(0xff564FCC),
                ),
        ),
      ),
    );
  }
}
