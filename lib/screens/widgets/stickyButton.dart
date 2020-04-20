import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StickyButton extends StatelessWidget {
  final _title;
  final _imgPath;
  final _function;

  StickyButton(this._title, this._imgPath, this._function) : super();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _function,
      child: Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(50.0),
                  bottomLeft: Radius.circular(50.0)),
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
          child: _title == "" && _imgPath == ""
              ? Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                )
              : _imgPath == ""
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          _title,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        )
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        SizedBox(
                          width: 10.0,
                        ),
                        _imgPath == "images/movie.svg"
                            ? SvgPicture.asset(
                                _imgPath,
                                width: 30.0,
                                height: 30.0,
                              )
                            : SvgPicture.asset(_imgPath),
                        SizedBox(
                          width: 5.0,
                        ),
                        Text(
                          _title,
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                        )
                      ],
                    )),
    );
  }
}
