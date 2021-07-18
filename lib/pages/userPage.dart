import 'package:flutter/material.dart';
import 'package:sql_treino/utils/functions.dart';

import 'package:sql_treino/utils/storage.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future validate() async {
    RAM ram = await RAM().load();
    Map data = await ram.readData();
    return data["logged"];
  }

  Widget buildBody(BuildContext context, AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.none:
      case ConnectionState.waiting:
        return Center(
          child: Text(
            "Carregando...",
            style: TextStyle(
              color: Colors.blueAccent,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        );
      default:
        if (snapshot.hasError || snapshot.data == null) {
          route(context, "/");
          return Container();
        } else {
          return Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Text(
                    "Você está logado com o seguinte email:\n'${snapshot.data}'",
                    style: TextStyle(
                      fontSize: 20,
                      height: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  button("Calculadora", Colors.green, Colors.lightBlue[100],
                      "calculator"),
                  button("Cálculo de IMC", Colors.grey[50], Colors.green,
                      "calculodeimc"),
                  button("Color Game", Colors.purple, Colors.grey, "colorgame"),
                  button("Conversor de Moedas", Colors.black,
                      Colors.amberAccent, "conversordemoedas"),
                  button("Todo List", Colors.grey[50], Colors.blue, "todolist"),
                  button("Workout Timer", Colors.purple[50], Colors.red,
                      "workouttimer-edit"),
                ],
              ),
            ),
          );
        }
    }
  }

  void logout() async {
    RAM ram = await RAM().load();
    await ram.editData("logged", null);
    route(context, "/");
  }

  Widget button(
      String text, Color textColor, Color background, String routeName) {
    return Container(
      width: 200,
      margin: EdgeInsets.all(10),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(background),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor),
        ),
        onPressed: () => route(context, "/$routeName"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text("Página do Usuário"),
          centerTitle: true,
          leading: TextButton(
              onPressed: logout,
              child: Text(
                "Log Out",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
        ),
        body: FutureBuilder(
          future: validate(),
          builder: buildBody,
        ),
      ),
    );
  }
}
