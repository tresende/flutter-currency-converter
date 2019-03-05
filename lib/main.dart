import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const request = 'https://api.hgbrasil.com/finance?key=';

void main() async {
  await DotEnv().load('.env');
  print(await getData());
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.white),
  ));
}

Future<Map> getData() async {
  Map env = DotEnv().env;
  http.Response response = await http.get(request + env['API_KEY']);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;
  double real;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _realChanged(String text) {
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void _dolarChanged(String text) {
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = ((dolar * this.dolar) / euro).toStringAsFixed(2);
  }

  void _euroChanged(String text) {
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    euroController.text = ((euro * this.euro) / dolar).toStringAsFixed(2);
  }

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
                    buildTextField(
                        "Reais", "R\$", realController, _realChanged),
                    Divider(),
                    buildTextField(
                        "Dólares", "\$", dolarController, _dolarChanged),
                    Divider(),
                    buildTextField("Euros", "€", euroController, _euroChanged),
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function onChanged) {
  return TextField(
    keyboardType: TextInputType.number,
    onChanged: onChanged,
    controller: controller,
    style: TextStyle(color: Colors.amber, fontSize: 20),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
  );
}
