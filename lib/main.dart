import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=8004b0aa';

void main() async {
  print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text("\$ Conversor \$"),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapeshot) {
          switch (snapeshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                  child: Text("Carregando Dados",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.amber, fontSize: 20)));
            default:
              if (snapeshot.hasError) {
                return Center(
                    child: Text("Erro ao Carregando Dados",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.amber, fontSize: 20)));
              }
              dolar = snapeshot.data["results"]["currencies"]["USD"]["buy"];
              euro = snapeshot.data["results"]["currencies"]["EUR"]["buy"];
              return SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Icon(
                      Icons.monetization_on,
                      size: 150,
                      color: Colors.amber,
                    ),
                    buildTextField("Reais", "R\$"),
                    Divider(),
                    buildTextField("Dólares", "\$"),
                    Divider(),
                    buildTextField("Euros", "€"),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix) {
  return TextField(
    style: TextStyle(color: Colors.amber, fontSize: 20),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
  );
}
