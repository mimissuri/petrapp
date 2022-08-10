import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:petrapp/ftext.dart';

List<String> gasolineras = [
  "alcampo",
  "avia",
  "bonarea",
  "bp",
  "carrefour",
  "cepsa",
  "esclat",
  "galp",
  "petrocat",
  "petronor",
  "repsol",
  "tamoil",
];

class Gasolinera extends StatelessWidget {
  final String _rotulo, _direccion;
  String _marca = "gasolinera";
  final double _preu, _distancia, _lat, _long;
  final bool _recomended;
  final Color pC = const Color(0xFF0A0B0D);
  final Color sC = const Color(0xFF12151C);

  Gasolinera(this._rotulo, this._direccion, this._preu, this._distancia,
      this._lat, this._long, this._recomended,
      {Key? key})
      : super(key: key) {
    String rotulo = _rotulo.toLowerCase();
    for (int i = 0; i < gasolineras.length; i++) {
      if (rotulo.contains(gasolineras[i])) {
        _marca = gasolineras[i];
        break;
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        MapsLauncher.launchCoordinates(_lat, _long);
      },
      child: Container(
        decoration: BoxDecoration(
          color: _recomended ? pC : sC,
          // border: Border.all(
          //   color: _recomended ? Colors.white : sC,
          //   width: 1,
          // ),
          borderRadius: BorderRadius.circular((height / width) * 3),
        ),
        padding: EdgeInsets.only(right: width * 0.05),
        height: height * 0.17,
        width: width * 0.85 + 2,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.only(left: width * 0.05, right: width * 0.03),
              width: width * 0.3,
              height: height * 0.17,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image(image: AssetImage("assets/$_marca.png")),
              ),
            ),
            SizedBox(
              width: width * 0.50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ftext("  $_rotulo", 20, Colors.white, FontWeight.w900,
                      TextAlign.end),
                  SizedBox(height: height * 0.005),
                  SizedBox(
                    width: width * 0.50,
                    height: height * 0.05,
                    child: Align(
                      alignment: Alignment.topRight,
                      child: ftext(
                          "${_distancia.toStringAsFixed(2)}km - $_direccion",
                          16,
                          Colors.white,
                          FontWeight.w400,
                          TextAlign.end),
                    ),
                  ),
                  ftext("  ${_preu.toStringAsFixed(3)} €/L", 35, Colors.white,
                      FontWeight.w900, TextAlign.end),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
