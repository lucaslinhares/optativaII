import 'package:flutter/material.dart';

class Emprestimo {
  String _tipoObjeto;
  String _nomePessoa;
  String _descricaoObjeto;
  //DateTime _data = DateTime.now();
  bool _concluido;

  String get objeto => _tipoObjeto;
  String get nomePessoa => _nomePessoa;
  String get descricao => _descricaoObjeto;
  //DateTime get data => _data;
  bool get concluido => _concluido;

  Emprestimo(this._tipoObjeto, this._nomePessoa, this._descricaoObjeto,
       this._concluido); //this._data,

  Map getEmprestimo() {
    Map<String, dynamic> emprestimo = Map();
    emprestimo["tipoObjeto"] = _tipoObjeto;
    emprestimo["nomePessoa"] = _nomePessoa;
    emprestimo["descricaoObjeto"] = _descricaoObjeto;
    //emprestimo["data"] = _data;
    emprestimo["concluido"] = _concluido;
    return emprestimo;
  }
}