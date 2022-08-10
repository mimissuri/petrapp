import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'dart:convert';
import 'package:petrapp/ftext.dart';
import 'package:petrapp/gasolinera.dart';
import 'dart:math' show cos, sqrt, asin, pow;

import 'package:shared_preferences/shared_preferences.dart';

final Map<String, int> dict = {
  "Biodiesel": 0,
  "Bioetanol": 1,
  "Gas Natural Comprimido": 2,
  "Gas Natural Licuado": 3,
  "Gases licuados del petróleo": 4,
  "Gasoleo A": 5,
  "Gasoleo B": 6,
  "Gasoleo Premium": 7,
  "Gasolina 95 E10": 8,
  "Gasolina 95 E5": 9,
  "Gasolina 95 E5 Premium": 10,
  "Gasolina 98 E10": 11,
  "Gasolina 98 E5": 12,
  "Hidrogeno": 13
};
final int NUMERO_GASOLINERAS = 25;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Petrapp());
}

class Petrapp extends StatelessWidget {
  const Petrapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Petrapp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

Future<LocationData> _determinePosition() async {
  Location location = Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  return await location.getLocation();
}

Future<List<dynamic>> fetchGasolineras() async {
  final prefs = await SharedPreferences.getInstance();
  final combustible = prefs.getString('combustible') ?? "Gasoleo A";
  final combustibleSeleccionado = dict[combustible]!;
  LocationData pos = await _determinePosition();
  final link =
      "https://petrapp-2003.herokuapp.com/getGasolineras/${pos.latitude}/${pos.longitude}/$NUMERO_GASOLINERAS/$combustibleSeleccionado";
  final response = await http.get(Uri.parse(link));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    for (int i = 0; i != data.length; i++) {
      (data[i]["data"] as List<dynamic>).add(calculateDistance(
          pos.latitude, pos.longitude, data[i]["lat"], data[i]["long"]));
      (data[i]["data"] as List<dynamic>).add(
          pow(double.parse(data[i]["data"][combustibleSeleccionado + 5]), 6) +
              pow(data[i]["data"][19], 1.5));
    }
    data.add(combustible);
    return data;
  } else {
    return Future.error(response);
  }
}

// Future<String> prefCombustible() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('Combustible') ?? "Gasoleo A";
// }

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() {
    return HomeState();
  }
}

class HomeState extends State<Home> {
  final Color pC = const Color(0xFF0A0B0D);
  final Color sC = const Color(0xFF0B0B0C);
  final Color tC = const Color(0xFF242C37);
  final Color dC = const Color(0xFF12151c);
  final Color rC = const Color(0xFFE93D3D);

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  late String combustible;
  late int combustibleSeleccionado;
  late Future<List<dynamic>> _data;
  String sortBy = "Relevancia";

  @override
  void initState() {
    super.initState();
    _data = fetchGasolineras();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // double statusHeight = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: tC,
      body: FutureBuilder<List<dynamic>>(
        future: _data,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              List<dynamic> data = snapshot.data as List<dynamic>;
              if (data.last.length != 3) {
                combustible = data.last;
                combustibleSeleccionado = dict[combustible]!;
                data.removeLast();
              }
              List<dynamic> dataRelevancia = List<dynamic>.from(data);
              dataRelevancia
                  .sort(((a, b) => a["data"][20].compareTo(b["data"][20])));
              if (sortBy == "Precio") {
                data.sort(((a, b) => a["data"][combustibleSeleccionado + 5]
                    .compareTo(b["data"][combustibleSeleccionado + 5])));
              } else if (sortBy == "Distancia") {
                data.sort(((a, b) => a["data"][19].compareTo(b["data"][19])));
              } else if (sortBy == "Relevancia") {
                data = dataRelevancia;
              } else {
                data.sort(((a, b) => a["data"][0].compareTo(b["data"][0])));
              }
              if (data.isEmpty) {
                return Stack(
                  children: [
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 50.0,
                          ),
                          SizedBox(height: height * 0.02),
                          const ftext(
                            "No se ha encontrado ninguna gasolinera.",
                            20.0,
                            Colors.white,
                            FontWeight.normal,
                            TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: height * 0.9,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        width: width * 0.5,
                        height: height * 0.06,
                        margin: EdgeInsets.only(
                            left: width * 0.15, right: width * 0.15),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 214, 214, 214),
                          borderRadius:
                              BorderRadius.circular((height / width) * 3),
                        ),
                        child: Center(
                          child: DropdownButton<String>(
                            value: combustible,
                            elevation: 16,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            dropdownColor: Color.fromARGB(255, 214, 214, 214),
                            onChanged: (String? newValue) async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('combustible', newValue!);
                              setState(() {
                                _data = fetchGasolineras();
                              });
                            },
                            underline: const SizedBox(),
                            items: <String>[
                              "Biodiesel",
                              "Bioetanol",
                              "Gas Natural Comprimido",
                              "Gas Natural Licuado",
                              "Gases licuados del petróleo",
                              "Gasoleo A",
                              "Gasoleo B",
                              "Gasoleo Premium",
                              "Gasolina 95 E10",
                              "Gasolina 95 E5",
                              "Gasolina 95 E5 Premium",
                              "Gasolina 98 E10",
                              "Gasolina 98 E5",
                              "Hidrogeno"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }
              return SizedBox(
                width: width,
                height: height,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(height: height * 0.1),
                        Gasolinera(
                          dataRelevancia[0]["data"][0],
                          dataRelevancia[0]["data"][4],
                          double.parse(dataRelevancia[0]["data"]
                              [combustibleSeleccionado + 5]),
                          dataRelevancia[0]["data"][19],
                          dataRelevancia[0]["lat"],
                          dataRelevancia[0]["long"],
                          true,
                        ),
                        SizedBox(
                          height: height * 0.08,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ftext(
                                snapshot.hasError
                                    ? snapshot.error.toString()
                                    : "Ordenar por",
                                20.0,
                                Colors.white,
                                FontWeight.normal,
                                TextAlign.center,
                              ),
                              SizedBox(width: width * 0.02),
                              DropdownButton<String>(
                                value: sortBy,
                                elevation: 16,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                dropdownColor: tC,
                                underline: const SizedBox(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    sortBy = newValue!;
                                  });
                                },
                                items: <String>[
                                  'Precio',
                                  'Distancia',
                                  'Relevancia',
                                  'Nombre',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: width * 0.85 + 2,
                          height: height * 0.65,
                          child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              padding: EdgeInsets.zero,
                              itemCount: data.length,
                              itemBuilder: (BuildContext context, int i) {
                                return Container(
                                  margin:
                                      EdgeInsets.only(bottom: height * 0.05),
                                  child: Gasolinera(
                                    data[i]["data"][0],
                                    data[i]["data"][4],
                                    double.parse(data[i]["data"]
                                        [combustibleSeleccionado + 5]),
                                    data[i]["data"][19],
                                    data[i]["lat"],
                                    data[i]["long"],
                                    false,
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                    Positioned(
                      top: height * 0.9,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        width: width * 0.5,
                        height: height * 0.06,
                        margin: EdgeInsets.only(
                            left: width * 0.15, right: width * 0.15),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 214, 214, 214),
                          borderRadius:
                              BorderRadius.circular((height / width) * 3),
                        ),
                        child: Center(
                          child: DropdownButton<String>(
                            value: combustible,
                            elevation: 16,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            dropdownColor: Color.fromARGB(255, 214, 214, 214),
                            onChanged: (String? newValue) async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('combustible', newValue!);
                              setState(() {
                                _data = fetchGasolineras();
                              });
                            },
                            underline: const SizedBox(),
                            items: <String>[
                              "Biodiesel",
                              "Bioetanol",
                              "Gas Natural Comprimido",
                              "Gas Natural Licuado",
                              "Gases licuados del petróleo",
                              "Gasoleo A",
                              "Gasoleo B",
                              "Gasoleo Premium",
                              "Gasolina 95 E10",
                              "Gasolina 95 E5",
                              "Gasolina 95 E5 Premium",
                              "Gasolina 98 E10",
                              "Gasolina 98 E5",
                              "Hidrogeno"
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Center(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.close,
                    color: Colors.red,
                    size: 50.0,
                  ),
                  SizedBox(height: height * 0.02),
                  ftext(
                    snapshot.hasError
                        ? snapshot.error.toString()
                        : "Couldn't load data",
                    20.0,
                    Colors.white,
                    FontWeight.normal,
                    TextAlign.center,
                  ),
                ],
              ));
            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
