import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';

class MyVideoProvider with ChangeNotifier {
  VideoPlayerController? _vCont;
  VideoPlayerController? get getVidCont => _vCont;
  bool isSaved = false;
  bool load = false;

  var _database;
  var _loadValue;

  void initializeVideoPlayer(String filePath) async {
    // inicializar el video player
    _vCont = await VideoPlayerController.file(File(filePath))
      ..addListener(() => notifyListeners())
      ..setLooping(false)
      ..initialize().then(
        (value) async {
          // 7: cargar el progreso guardado del video
        },
      );
  }

  void isPlayOrPause(bool isPlay) {
    if (isPlay) {
      _vCont!.pause();
    } else {
      _vCont!.play();
    }
    notifyListeners();
  }

  //  6: cargar datos
  Future<void> loadConfigs() async {
    if (_database == null) {
      await _connectDatabase();
      await _getPosition();
    }

    _vCont!.seekTo(
      Duration(
        seconds: int.parse(_loadValue.toString().substring(21, 22)),
        milliseconds: int.parse(_loadValue.toString().substring(23, 26)),
      ),
    );
  }

  //  10: guardar datos
  Future saveConfigs() async {
    try {
      if (_database == null) {
        await _connectDatabase();
        await _getPosition();
      }
      print(_loadValue.toString() == "[]");
      if (_loadValue.toString() == "[]") {
        await _insertPosition();
      } else {
        await _updatePosition();
      }

      await _getPosition();
      isSaved = true;
      notifyListeners();
    } catch (e) {
      print("Error al guardar: ${e.toString()}");
      isSaved = false;
      notifyListeners();
    }
  }

  Future<void> _connectDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'video.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE vpointer(id INTEGER PRIMARY KEY, time TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> _insertPosition() async {
    await _database.insert(
        'vpointer', {"id": 1, "time": _vCont!.value.position.toString()});
  }

  Future<void> _updatePosition() async {
    await _database.update(
      'vpointer',
      {"time": _vCont!.value.position.toString()},
      where: 'id = 1',
    );
  }

  Future<void> _getPosition() async {
    _loadValue = await _database.query('vpointer', where: 'id = 1');
    // print("SECONDS: ${_loadValue.toString().substring(21, 22)}");
    // print("MILISECONDS: ${_loadValue.toString().substring(23, 26)}");
  }
}
