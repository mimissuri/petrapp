import 'package:flutter/material.dart';

class ftext extends StatelessWidget {
  final String _text;
  final double _size;
  final Color _color;
  final FontWeight _weight;
  final TextAlign _align;

  const ftext(this._text, this._size, this._color, this._weight, this._align,
      {Key? key})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Text(
      _text,
      textAlign: _align,
      style: TextStyle(
        fontFamily: 'Montserrat',
        fontSize: width * _size / 500,
        color: _color,
        fontWeight: _weight,
      ),
    );
  }
}
