

import 'package:flutter/material.dart';
import 'package:trabalho_emprestimo/model/Emprestimo.dart';
import 'package:trabalho_emprestimo/persistence/ManipulaArquivo.dart';
import 'dart:convert';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  ManipulaArquivo manipulaArquivo = ManipulaArquivo();

  final _tipoObjetoController = TextEditingController();
  final _nomePessoaController = TextEditingController();
  final _descricaoObjetoController = TextEditingController();

  Map<String, dynamic> _ultimoRemovido;
  int _ultimoRemovidoPos;
  List _emprestimoList = [];
  DateTime _dataInfo = DateTime.now();

  @override
  void initState() {
    super.initState();
    manipulaArquivo.readEmprestimo().then((dado) {
      setState(() {
        _emprestimoList = json.decode(dado);
      });
    });
  }

  void _addEmprestimo() {
    setState(() {
      Map<String, dynamic> novoEmprestimo = Map();
      Emprestimo emprestimo = Emprestimo(
          _tipoObjetoController.text,
          _nomePessoaController.text,
          _descricaoObjetoController.text,
          // _dataInfo,
          false);
      novoEmprestimo = emprestimo.getEmprestimo();
      _tipoObjetoController.text = "";
      _nomePessoaController.text = "";
      _descricaoObjetoController.text = "";
      _emprestimoList.add(novoEmprestimo);
      manipulaArquivo.saveEmprestimo(_emprestimoList);
    });
  }

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _emprestimoList.sort((a, b) {
        if (a["concluido"] && !b["concluido"])
          return 1;
        else if (!a["concluido"] && b["concluido"])
          return -1;
        else
          return 0;
      });
      manipulaArquivo.saveEmprestimo(_emprestimoList);
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de Empréstimos"),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(18.0, 8.0, 18.0, 8.0),
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: "Tipo do objeto"),
                  controller: _tipoObjetoController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Nome da pessoa"),
                  controller: _nomePessoaController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Descrição do objeto"),
                  controller: _descricaoObjetoController,
                ),
                FlatButton(
                  child: Row(
                    children: <Widget>[
                      Text(
                          "${_dataInfo.day}/${_dataInfo.month}/${_dataInfo.year}"),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                  onPressed: () async {
                    final dataSelecionada = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1967),
                      lastDate: DateTime(_dataInfo.year + 1),
                      builder: (BuildContext context, Widget child) {
                        return Theme(
                          data: ThemeData.dark(),
                          child: child,
                        );
                      },
                    );
                    if (dataSelecionada != null &&
                        dataSelecionada != _dataInfo) {
                      setState(() {
                        _dataInfo = dataSelecionada as DateTime;
                      });
                    }
                  },
                ),
                RaisedButton(
                  child: Text("+ Adicionar"),
                  textColor: Colors.white,
                  onPressed: () {
                    _addEmprestimo();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10.0),
                  itemCount: _emprestimoList.length,
                  itemBuilder: buildItem),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text('''
            ${_emprestimoList[index]["tipoObjeto"]}
            ${_emprestimoList[index]["nomePessoa"]}
            ${_emprestimoList[index]["descricaoObjeto"]}
            ${_dataInfo.day}/${_dataInfo.month}/${_dataInfo.year}
            '''),
        value: _emprestimoList[index]["concluido"],
        secondary: CircleAvatar(
          child: Icon(
              _emprestimoList[index]["concluido"] ? Icons.check : Icons.error),
        ),
        onChanged: (c) {
          setState(() {
            _emprestimoList[index]["concluido"] = c;
            manipulaArquivo.saveEmprestimo(_emprestimoList);
          });
        },
      ),
      onDismissed: (direction) {
        setState(() {
          _ultimoRemovido = Map.from(_emprestimoList[index]);
          _ultimoRemovidoPos = index;
          _emprestimoList.removeAt(index);
          manipulaArquivo.saveEmprestimo(_emprestimoList);
          final snack = SnackBar(
            content: Text(
                "Empréstimo \"${_ultimoRemovido["tipoObjeto"]}\"removido!"),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _emprestimoList.insert(_ultimoRemovidoPos, _ultimoRemovido);
                    manipulaArquivo.saveEmprestimo(_emprestimoList);
                  });
                }),
            duration: Duration(seconds: 2),
          );
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }
}

