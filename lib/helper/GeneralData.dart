import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/model/CameraThumbnail.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/model/EntityOverride.dart';
import 'package:hasskit/model/LoginData.dart';
import 'package:hasskit/model/Room.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import 'Logger.dart';
import 'MaterialDesignIcons.dart';

GeneralData gd = GeneralData();
Random random = Random();

enum ViewMode {
  normal,
  edit,
  sort,
}

class GeneralData with ChangeNotifier {
  void saveBool(String key, bool content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setBool(key, content);
    log.d('saveBool: key $key content $content');
  }

  Future<bool> getBool(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getBool(key) ?? false;
    return value;
  }

  void saveString(String key, String content) async {
    var _preferences = await SharedPreferences.getInstance();
    _preferences.setString(key, content);
    log.d('saveString: key $key content $content');
  }

  Future<String> getString(String key) async {
    var _preferences = await SharedPreferences.getInstance();
    var value = _preferences.getString(key) ?? '';
    return value;
  }

  double _mediaQueryWidth = 411.42857142857144;

  double get mediaQueryWidth => _mediaQueryWidth;

  set mediaQueryWidth(double val) {
//    log.d('mediaQueryWidth $val');
    if (val == null) {
      throw new ArgumentError();
    }
    if (_mediaQueryWidth != val) {
      _mediaQueryWidth = val;
      notifyListeners();
    }
  }

  double _mediaQueryHeight = 0;

  double get mediaQueryHeight => _mediaQueryHeight;

  set mediaQueryHeight(double val) {
//    log.d('mediaQueryHeight $val');
    if (val == null) {
      throw new ArgumentError();
    }
    if (_mediaQueryHeight != val) {
      _mediaQueryHeight = val;
      notifyListeners();
    }
  }

  double get textScaleFactor {
    return mediaQueryWidth / 411.42857142857144;
  }

  int _lastSelectedRoom = 0;

  int get lastSelectedRoom => _lastSelectedRoom;

  set lastSelectedRoom(int val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_lastSelectedRoom != val) {
      _lastSelectedRoom = val;
      notifyListeners();
    }
  }

  String _connectionStatus = '';

  String get connectionStatus => _connectionStatus;

  set connectionStatus(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_connectionStatus != val) {
      _connectionStatus = val;
//      if (val == "Connected") {
//        gd.getSettings("val == Connected");
//      }
      notifyListeners();
    }
  }

  bool get showSpin {
    if (connectionStatus != 'Connected' &&
        gd.connectionOnDataTime
            .add(Duration(seconds: 10))
            .isBefore(DateTime.now())) {
      return true;
    }
    return false;
  }

  DateTime connectionOnDataTime;

  String _urlTextField = '';

  String get urlTextField => _urlTextField;

  set urlTextField(String val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_urlTextField != val) {
      _urlTextField = val;
      notifyListeners();
    }
  }

  void sendHttpPost(String url, String authCode, BuildContext context) async {
    log.d('httpPost $url '
        '\nauthCode $authCode');
    Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    var body = 'grant_type=authorization_code'
        '&code=$authCode&client_id=$url/hasskit';
    http
        .post(url + '/auth/token', headers: headers, body: body)
        .then((response) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        gd.connectionStatus =
            'Got response from server with code ${response.statusCode}';

        var bodyDecode = json.decode(response.body);
        var loginData = LoginData.fromJson(bodyDecode);
        loginData.url = url;
//        log.d('bodyDecode $bodyDecode\n'
//            'url ${loginData.url}\n'
//            'longToken ${loginData.longToken}\n'
//            'accessToken ${loginData.accessToken}\n'
//            'expiresIn ${loginData.expiresIn}\n'
//            'refreshToken ${loginData.refreshToken}\n'
//            'tokenType ${loginData.tokenType}\n'
//            'lastAccess ${loginData.lastAccess}\n'
//            '');
        log.d("loginData.url ${loginData.url}");
        log.d("longToken.url ${loginData.longToken}");
        log.d("accessToken.url ${loginData.accessToken}");
        log.d("expiresIn.url ${loginData.expiresIn}");
        log.d("refreshToken.url ${loginData.refreshToken}");
        log.d("tokenType.url ${loginData.tokenType}");
        log.d("lastAccess.url ${loginData.lastAccess}");

        gd.loginDataCurrent = loginData;
        gd.loginDataListAdd(loginData, "sendHttpPost");
        loginDataListSortAndSave("sendHttpPost");
        webSocket.initCommunication();
        gd.connectionStatus =
            'Init Websocket Communication to ${loginDataCurrent.getUrl}';
        log.w(gd.connectionStatus);
        Navigator.pop(context, gd.connectionStatus);
      } else {
        gd.connectionStatus =
            'Error response from server with code ${response.statusCode}';
        Navigator.pop(context, gd.connectionStatus);
      }
    }).catchError((e) {
      gd.connectionStatus = 'Error response from server with code $e';
      Navigator.pop(context, gd.connectionStatus);
    });
  }

  Map<String, Entity> _entities = {};

//  List<Entity> _entities = [];
  UnmodifiableMapView<String, Entity> get entities {
    return UnmodifiableMapView(_entities);
  }

  void getStates(List<dynamic> message) {
    log.d('getStates');
    _entities.clear();
    _entities = {};

    for (dynamic mess in message) {
      Entity entity = Entity.fromJson(mess);
      if (entity == null || entity.entityId == null) {
        log.e('getStates entity.entityId');
        continue;
      }
//      if (entity.supportedFeatures != null) {
//        log.d(
//            "${entity.entityId} supportedFeatures ${entity.supportedFeatures}");
//      }
      _entities[entity.entityId] = entity;
    }

//    log.d('_entities.length ${entities.length}');
    log.d('_entities.length ${_entities.length}');
    notifyListeners();
  }

  List<String> lovelaceEntities = [];

  void getLovelaceConfig(dynamic message) {
    log.d('getLovelaceConfig');

    List<dynamic> viewsParse = message['result']['views'];
//    log.d('viewsParse.length ${viewsParse.length}');

    for (var viewParse in viewsParse) {
      List<dynamic> badgesParse = viewParse['badges'];
      for (var badgeParse in badgesParse) {
        badgeParse = processEntityId(badgeParse.toString());
//        log.d('badgeParse $badgeParse');
        if (isEntityNameValid(badgeParse) &&
            !lovelaceEntities.contains(badgeParse)) {
          lovelaceEntities.add(badgeParse);
        }
      }

      List<dynamic> cardsParse = viewParse['cards'];

      for (var cardParse in cardsParse) {
        var type = cardParse['type'];
        if (type == 'entities' || type == 'glance') {
          List<dynamic> entitiesParse = cardParse['entities'];
          for (var entityParse in entitiesParse) {
            entityParse = processEntityId(entityParse.toString());
//            log.d('entityParse 1 $entityParse');
            if (isEntityNameValid(entityParse) &&
                !lovelaceEntities.contains(entityParse)) {
              lovelaceEntities.add(entityParse);
            }
          }
        } else {
          var entityParse = cardParse['entity'];
          entityParse = processEntityId(entityParse.toString());
//          log.d('entityParse 2 $entityParse');
          if (isEntityNameValid(entityParse) &&
              !lovelaceEntities.contains(entityParse)) {
            lovelaceEntities.add(entityParse);
          }
        }
      }
    }

//    log.d('lovelaceEntities.length ${lovelaceEntities.length} ');

//    int i = 1;
//    for (var entity in lovelaceEntities) {
//      log.d('$i. lovelaceEntities $entity');
//      i++;
//    }
    notifyListeners();
  }

  void socketSubscribeEvents(dynamic message) {
//    print('socketSubscribeEvents $message');
    Entity newEntity = Entity.fromJson(message['event']['data']['new_state']);
    if (newEntity == null || newEntity.entityId == null) {
      log.e('socketSubscribeEvents newEntity == null');
      return;
    }

    if (newEntity.entityId.contains("climate.")) {
      log.d(
          "\nsocketSubscribeEvents fan. ${message['event']['data']['new_state']}");
    }

//    _entities[newEntity.entityId] = newEntity;
//    return;

    Entity oldEntity = entities[newEntity.entityId];

    if (oldEntity != null) {
      oldEntity.state = newEntity.state;
      oldEntity.icon = newEntity.icon;
      oldEntity.friendlyName = newEntity.friendlyName;

//      if (newEntity.entityId.contains('climate.')) {
      oldEntity.hvacModes = newEntity.hvacModes;
      oldEntity.minTemp = newEntity.minTemp;
      oldEntity.maxTemp = newEntity.maxTemp;
      oldEntity.targetTempStep = newEntity.targetTempStep;
      oldEntity.currentTemperature = newEntity.currentTemperature;
      oldEntity.temperature = newEntity.temperature;
      oldEntity.fanMode = newEntity.fanMode;
      oldEntity.fanModes = newEntity.fanModes;
      oldEntity.deviceCode = newEntity.deviceCode;
      oldEntity.manufacturer = newEntity.manufacturer;
//      }

//      if (newEntity.entityId.contains('fan.')) {
      oldEntity.speedList = newEntity.speedList;
      oldEntity.oscillating = newEntity.oscillating;
      oldEntity.speedLevel = newEntity.speedLevel;
      oldEntity.speed = newEntity.speed;
      oldEntity.angle = newEntity.angle;
      oldEntity.directSpeed = newEntity.directSpeed;
//      }

//      if (newEntity.entityId.contains('light.')) {
      oldEntity.supportedFeatures = newEntity.supportedFeatures;
      oldEntity.brightness = newEntity.brightness;
      oldEntity.rgbColor = newEntity.rgbColor;
      oldEntity.minMireds = newEntity.minMireds;
      oldEntity.maxMireds = newEntity.maxMireds;
      oldEntity.colorTemp = newEntity.colorTemp;
//    }
      notifyListeners();
    } else {
      _entities[newEntity.entityId] = newEntity;
      log.e('WTF newEntity ${newEntity.entityId}');
      notifyListeners();
    }
  }

  bool isEntityNameValid(String entityId) {
    if (entityId == null) {
//      log.d('isEntityNameValid entityName null');
      return false;
    }

    if (!entityId.contains('.')) {
//      log.d('isEntityNameValid $entityId not valid');
      return false;
    }
    return true;
  }

  String processEntityId(String entityId) {
    if (entityId == null) {
      log.e('processEntityId String entityId null');
      return null;
    }

    String entityIdOriginal = entityId;
    entityId = entityId.split(',').first;

    if (!entityId.contains('.')) {
      log.e('processEntityId $entityIdOriginal not valid');
      return null;
    }

    entityId = entityId.replaceAll('{entity: ', '');
    entityId = entityId.replaceAll('}', '');

    return entityId;
  }

  Map<String, CameraThumbnail> cameraThumbnails = {};
  Map<String, DateTime> activeCameras = {};
  Map<String, ImageProvider> cameraThumbnailsOld = {};
  Map<int, String> cameraThumbnailsId = {};

  ImageProvider getCameraThumbnailOld(String entityId) {
    if (cameraThumbnailsOld[entityId] == null) {
      cameraThumbnailsOld[entityId] = AssetImage('assets/images/loader.png');
    }
    return cameraThumbnailsOld[entityId];
  }

  ImageProvider getCameraThumbnail(String entityId) {
    if (cameraThumbnails[entityId] == null) {
      return cameraThumbnailsOld[entityId];
    }
    return cameraThumbnails[entityId].image;
  }

  DateTime getCameraLastUpdate(String entityId) {
    if (cameraThumbnails[entityId] == null) {
      return DateTime.now().subtract(Duration(days: 1));
    }
    return cameraThumbnails[entityId].receivedDateTime;
  }

  void requestCameraImage(String entityId, {bool force = false}) {
    if (entityId == null ||
        activeCameras[entityId] != null &&
            activeCameras[entityId].isAfter(DateTime.now())) {
      return;
    }

    if (cameraThumbnails[entityId] == null ||
        cameraThumbnails[entityId]
            .receivedDateTime
            .isBefore(DateTime.now().subtract(Duration(seconds: 10)))) {
      var outMsg = {
        'id': gd.socketId,
        'type': 'camera_thumbnail',
        'entity_id': entityId,
      };
      webSocket.send(jsonEncode(outMsg));
      activeCameras[entityId] = DateTime.now().add(Duration(seconds: 10));
//      log.d('requestCameraImage $entityId');
    }
  }

  void camerasThumbnailUpdate(String entityId, String content) async {
    CameraThumbnail cameraThumbnail = CameraThumbnail(
      entityId: entityId,
      receivedDateTime: DateTime.now(),
      image: MemoryImage(base64Decode(content)),
    );
    cameraThumbnails[entityId] = cameraThumbnail;
//    log.d('camerasThumbnailUpdate $entityId');
//    log.d('cameraThumbnails.length ${cameraThumbnails.length}');
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1000));
    cameraThumbnailsOld[entityId] = cameraThumbnails[entityId].image;
//    log.d('oldImage.length ${cameraThumbnailsOld.length}');
    notifyListeners();
  }

  String timePassed(DateTime previousTime) {
    var totalDiff = DateTime.now().difference(previousTime).inMilliseconds;
    var duration = Duration(milliseconds: totalDiff);
    var format =
        '${duration.inDays}:${duration.inHours.remainder(24)}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}';
    var spit = format.split(':');
    var recVal = '';
    bool lessThanASecond = true;

    var day = int.parse(spit[0]);
    var hour = int.parse(spit[1]);
    var minute = int.parse(spit[2]);
    var second = int.parse(spit[3]);

    if (day > 365) {
      return '...';
    }
    if (day > 0) {
      String s = ' day, ';
      if (day > 1) {
        s = ' days, ';
      }
      recVal = recVal + day.toString() + s;
      lessThanASecond = false;
    }
    if (hour > 0 || !lessThanASecond) {
      String s = ' hour, ';
      if (hour > 1) {
        s = ' hours, ';
      }
      recVal = recVal + hour.toString() + s;
      lessThanASecond = false;
    }
    if (minute > 0 || !lessThanASecond) {
      String s = ' minute, ';
      if (minute > 1) {
        s = ' minutes, ';
      }
      recVal = recVal + minute.toString() + s;
      lessThanASecond = false;
    }
    String s = ' s';
    recVal = recVal + second.toString() + s;

    return recVal;
  }

  ThemeData get currentTheme {
    return ThemeInfo.themesData[themeIndex];
  }

  int _themeIndex = 1;

  int get themeIndex => _themeIndex;

  set themeIndex(int value) {
    {
      if (_themeIndex != value) {
        _themeIndex = value;
        notifyListeners();
      }
    }
  }

  int _itemsPerRow = 3;

  int get itemsPerRow => _itemsPerRow;

  set itemsPerRow(int value) {
    {
      if (_itemsPerRow != value) {
        _itemsPerRow = value;
        notifyListeners();
      }
    }
  }

  themeChange() {
    themeIndex = themeIndex + 1;
    if (themeIndex >= ThemeInfo.themesData.length) {
      themeIndex = 0;
    }
    log.d('themeIndex $themeIndex');
    notifyListeners();
  }

  List<LoginData> loginDataList = [];

  int get loginDataListLength {
    return loginDataList.length;
  }

  LoginData loginDataHassKitDemo = LoginData(
    url: "http://hasskitdemo.duckdns.org:8123",
    accessToken:
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiI4NWRlNWM4MmE4OGQ0YmYxOTk4ZjgxZGE3YzY3ZWFkNSIsImlhdCI6MTU3MzY5Mzg2NiwiZXhwIjoxNTczNjk1NjY2fQ.GDWWYGshuxPOrv3GMOjqlxKUtPVh5sADzgTUutDp508",
    longToken:
        "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjZmNkOTk4ZjJiOTE0NjAwOThhNzJlYmQzZTk4NmFhYyIsImlhdCI6MTU3MzY5Mzg2NywiZXhwIjoxNjA1MjI5ODY3fQ.iUOXvErg3B6FyNqIpBZptXzzJSb4ib6E35PJ7XPrtJ4",
    expiresIn: 1800,
    refreshToken:
        "72b2bb75f7363a657031cb3389f1c66a22826154f95fbcd7a6b606a02e797d391898f87b0fef8eff107f35b0f8cc2ad995f3c70d3f609e82ff5f2eec9b0cba3b",
    tokenType: "Bearer",
    lastAccess: 1573693868837,
  );

  LoginData loginDataCurrent = LoginData();

  String _loginDataListString;

  String get loginDataListString => _loginDataListString;

  set loginDataListString(val) {
    if (val == _loginDataListString) return;

    _loginDataListString = val;

    if (_loginDataListString != null && _loginDataListString.length > 0) {
      List<dynamic> loginDataListString = jsonDecode(_loginDataListString);
      loginDataList = [];
      for (var loginData in loginDataListString) {
        LoginData newLoginData = LoginData(
          url: loginData['url'],
          longToken: loginData['longToken'],
          accessToken: loginData['accessToken'],
          expiresIn: loginData['expiresIn'],
          refreshToken: loginData['refreshToken'],
          tokenType: loginData['tokenType'],
          lastAccess: loginData['lastAccess'],
        );
        log.d('loginDataListAdd url ${newLoginData.url}');

        loginDataListAdd(newLoginData, "loginDataListString");
      }
      log.d('loginDataList.length ${loginDataList.length}');
    } else {
      log.w('CAN NOT FIND loginDataList');
    }

    if (gd.loginDataList.length > 0) {
      loginDataCurrent = gd.loginDataList[0];
      if (gd.autoConnect && gd.connectionStatus != "Connected") {
        log.w('Auto connect to ${loginDataCurrent.getUrl}');
        webSocket.initCommunication();
      }
    }
  }

  void loginDataListAdd(LoginData loginData, String from) {
    log.d('LoginData.loginDataListAdd ${loginData.url} from $from');
    var loginDataOld = loginDataList
        .firstWhere((rec) => rec.getUrl == loginData.url, orElse: () => null);
    if (loginDataOld == null) {
      loginDataList.add(loginData);
      log.d('loginDataListAdd ${loginData.url}');
    } else {
      loginDataOld.url = loginData.url;
      loginDataOld.accessToken = loginData.accessToken;
      loginDataOld.longToken = loginData.longToken;
      loginDataOld.expiresIn = loginData.expiresIn;
      loginDataOld.refreshToken = loginData.refreshToken;
      loginDataOld.tokenType = loginData.tokenType;
      loginDataOld.lastAccess = DateTime.now().toUtc().millisecondsSinceEpoch;
      log.e('loginDataListAdd ALREADY HAVE ${loginData.url}');
    }
    notifyListeners();
  }

  void loginDataListSortAndSave(String debug) {
//    log.e('LoginData.loginDataListSortAndSave $debug');
    try {
      if (loginDataList != null && loginDataList.length > 0) {
        loginDataList.sort((a, b) => b.lastAccess.compareTo(a.lastAccess));
        gd.saveString('loginDataList', jsonEncode(loginDataList));
        log.d('loginDataList.length ${loginDataList.length}');
      } else {
        gd.saveString('loginDataList', jsonEncode(loginDataList));
//        log.d('LoginData.loginDataListSortAndSave NO DATA');
      }
      notifyListeners();
//      loginDataListSortAndSaveFirebaseTimer(10);
    } catch (e) {
      log.w("loginDataListSortAndSave $e");
    }
  }

  void loginDataListDelete(LoginData loginData) {
    log.d('LoginData.loginDataListDelete ${loginData.url}');
    if (loginData != null) {
      loginDataList.remove(loginData);
      log.d('loginDataList.remove ${loginData.url}');
    } else {
      log.e('loginDataList.remove Can not find ${loginData.url}');
    }
    loginDataListSortAndSave("loginDataListDelete");
  }

  get socketUrl {
    String recVal = loginDataCurrent.url;
    recVal = recVal.replaceAll('http', 'ws');
    recVal = recVal + '/api/websocket';
    return recVal;
  }

  int _socketId = 0;

  get socketId => _socketId;

  set socketId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_socketId != value) {
      _socketId = value;
      notifyListeners();
    }
  }

  void socketIdIncrement() {
    socketId = socketId + 1;
  }

  int _subscribeEventsId = 0;

  get subscribeEventsId => _subscribeEventsId;

  set subscribeEventsId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_subscribeEventsId != value) {
      _subscribeEventsId = value;
      notifyListeners();
    }
  }

  int _longTokenId = 0;

  get longTokenId => _longTokenId;

  set longTokenId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_longTokenId != value) {
      _longTokenId = value;
      notifyListeners();
    }
  }

  int _getStatesId = 0;

  get getStatesId => _getStatesId;

  set getStatesId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_getStatesId != value) {
      _getStatesId = value;
      notifyListeners();
    }
  }

  int _loveLaceConfigId = 0;

  get loveLaceConfigId => _loveLaceConfigId;

  set loveLaceConfigId(int value) {
    if (value == null) {
      throw new ArgumentError();
    }
    if (_loveLaceConfigId != value) {
      _loveLaceConfigId = value;
      notifyListeners();
    }
  }

  bool _useSSL = false;

  get useSSL => _useSSL;

  set useSSL(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_useSSL != value) {
      _useSSL = value;
      notifyListeners();
    }
  }

  bool _autoConnect = true;

  get autoConnect => _autoConnect;

  set autoConnect(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_autoConnect != value) {
      _autoConnect = value;
      notifyListeners();
    }
  }

  bool _webViewLoading = false;

  bool get webViewLoading {
    return _webViewLoading;
  }

  set webViewLoading(bool value) {
    if (value != true && value != false) {
      throw new ArgumentError();
    }
    if (_webViewLoading != value) {
      _webViewLoading = value;
      notifyListeners();
    }
  }

//  bool _showLoading = false;
//  bool get showLoading {
//    return _showLoading;
//  }
//
//  set showLoading(bool value) {
//    if (value != true && value != false) {
//      throw new ArgumentError();
//    }
//    if (_showLoading != value) {
//      _showLoading = value;
//      notifyListeners();
//    }
//  }

  String trimUrl(String url) {
    url = url.trim();
    if (url.substring(url.length - 1, url.length) == '/') {
      url = url.substring(0, url.length - 1);
      log.w('$url contain last /');
    }
    return url;
  }

  List<Room> roomList = [];
  List<Room> roomListDefault = [
    Room(
        name: 'Home',
        imageIndex: 12,
        favorites: [],
        entities: [],
        row3: [],
        row4: []),
    Room(
        name: 'Living Room',
        imageIndex: 13,
        favorites: [],
        entities: [],
        row3: [],
        row4: []),
    Room(
        name: 'Kitchen',
        imageIndex: 14,
        favorites: [],
        entities: [],
        row3: [],
        row4: []),
    Room(
        name: 'Bedroom',
        imageIndex: 15,
        favorites: [],
        entities: [],
        row3: [],
        row4: []),
  ];

  List<Room> roomListHassKitDemo = [
    Room(
        name: 'HassKit Demo',
        imageIndex: 12,
        tempEntityId: "sensor.temperature_158d0002e98f27",
        favorites: [
          "fan.acorn_fan",
          "climate.air_conditioner_1",
          "cover.cover_03",
          "cover.cover_06",
          "lock.lock_9",
        ],
        entities: [
          "camera.camera_1",
          "camera.camera_2",
        ],
        row3: [
          "switch.socket_sonoff_s20",
          "switch.tuya_neo_coolcam_10a",
          "light.gateway_light_7c49eb891797",
        ],
        row4: [
          "climate.air_conditioner_2",
          "climate.air_conditioner_3",
          "climate.air_conditioner_4",
          "climate.air_conditioner_5",
          "fan.kaze_fan",
          "fan.lucci_air_fan",
          "fan.super_fan",
        ]),
    Room(
        name: 'Living Room',
        imageIndex: 13,
        tempEntityId: "sensor.aeotec_temperature_27",
        favorites: [
          "climate.air_conditioner_2",
          "climate.air_conditioner_3",
          "cover.cover_01",
          "cover.cover_02",
          "cover.cover_04",
          "fan.kaze_fan",
          "light.light_03",
          "light.light_02",
          "fan.lucci_air_fan",
          "camera.camera_1",
        ],
        entities: [],
        row3: [],
        row4: []),
    Room(
        name: 'Kitchen',
        imageIndex: 14,
        tempEntityId: "sensor.fibaro_temperature_31",
        favorites: [
          "camera.camera_2",
          "switch.aeotec_motion_26",
          "climate.air_conditioner_4",
          "climate.air_conditioner_5",
          "light.light_04",
          "light.light_05",
          "cover.cover_07",
          "cover.cover_08",
          "fan.super_fan",
          "cover.cover_09",
        ],
        entities: [],
        row3: [],
        row4: []),
    Room(
        name: 'Bedroom',
        imageIndex: 15,
        tempEntityId: "sensor.temperature_158d0002e98f27",
        favorites: [
          "climate.air_conditioner_2",
          "cover.cover_07",
          "cover.cover_08",
          "switch.socket_sonoff_s20",
          "switch.tuya_neo_coolcam_10a",
        ],
        entities: [],
        row3: [],
        row4: []),
  ];

  void roomListClear() {
    roomList.clear();
    roomList = [];
    notifyListeners();
  }

  int get roomListLength {
    if (roomList.length - 1 < 0) {
      return 0;
    }
    return roomList.length - 1;
  }

  String getRoomName(int roomIndex) {
    if (roomList.length > roomIndex && roomList[roomIndex].name != null) {
      return roomList[roomIndex].name;
    }
    return 'HassKit';
  }

  void roomEntitySort(
    int roomIndex,
    int rowNumber,
    String oldEntityId,
    String newEntityId,
  ) {
    log.w('roomEntitySwap oldEntityId $oldEntityId newEntityId $newEntityId');
    var entitiesRef;
    if (rowNumber == 1) {
      entitiesRef = gd.roomList[roomIndex].favorites;
    } else if (rowNumber == 2) {
      entitiesRef = gd.roomList[roomIndex].entities;
    } else if (rowNumber == 3) {
      entitiesRef = gd.roomList[roomIndex].row3;
    } else {
      entitiesRef = gd.roomList[roomIndex].row4;
    }

    int oldIndex = entitiesRef.indexOf(oldEntityId);
    int newIndex = entitiesRef.indexOf(newEntityId);
    String removedString = entitiesRef.removeAt(oldIndex);
    entitiesRef.insert(newIndex, removedString);
    notifyListeners();
    roomListSave();
  }

  AssetImage getRoomImage(int roomIndex) {
    if (roomList.length > roomIndex &&
        roomList[roomIndex] != null &&
        roomList[roomIndex].imageIndex != null) {
      return AssetImage(backgroundImage[roomList[roomIndex].imageIndex]);
    }
    return AssetImage(backgroundImage[4]);
  }

  List<String> backgroundImage = [
    'assets/background_images/Dark Blue.jpg',
    'assets/background_images/Dark Green.jpg',
    'assets/background_images/Light Blue.jpg',
    'assets/background_images/Light Green.jpg',
    'assets/background_images/Orange.jpg',
    'assets/background_images/Red.jpg',
    'assets/background_images/Blue Gradient.jpg',
    'assets/background_images/Green Gradient.jpg',
    'assets/background_images/Yellow Gradient.jpg',
    'assets/background_images/White Gradient.jpg',
    'assets/background_images/Black Gradient.jpg',
    'assets/background_images/Light Pink.jpg',
    'assets/background_images/Abstract 1.jpg',
    'assets/background_images/Abstract 2.jpg',
    'assets/background_images/Abstract 3.jpg',
    'assets/background_images/Abstract 4.jpg',
    'assets/background_images/Abstract 5.jpg',
  ];

  setRoomBackgroundImage(Room room, int backgroundImageIndex) {
    if (room.imageIndex != backgroundImageIndex) {
      room.imageIndex = backgroundImageIndex;
      notifyListeners();
    }
    roomListSave();
  }

  setRoomName(Room room, String name) {
    log.w('setRoomName room.name ${room.name} name $name');
    if (room.name != name) {
      room.name = name;
      notifyListeners();
    }
    roomListSave();
  }

  setRoomBackgroundAndName(Room room, int backgroundImageIndex, String name) {
    setRoomBackgroundImage(room, backgroundImageIndex);
    setRoomName(room, name);
  }

  deleteRoom(int roomIndex) async {
    log.w('deleteRoom roomIndex $roomIndex');
    if (roomList.length > roomIndex) {
      pageController.animateToPage(
        roomIndex,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      roomList.removeAt(roomIndex);
      pageController.jumpToPage(roomIndex - 1);
      notifyListeners();
    }
    roomListSave();
  }

  PageController pageController;

  addRoom(int fromPageIndex) async {
    log.w('addRoom');
    var millisecondsSinceEpoch =
        DateTime.now().millisecondsSinceEpoch.toString();
    millisecondsSinceEpoch = millisecondsSinceEpoch.substring(
        millisecondsSinceEpoch.length - 4, millisecondsSinceEpoch.length);
    var newRoom = Room(
      name: 'Room ' + millisecondsSinceEpoch,
      imageIndex: random.nextInt(gd.backgroundImage.length),
      favorites: [],
      entities: [],
      row3: [],
      row4: [],
    );

    roomList.insert(fromPageIndex + 1, newRoom);
    pageController.animateToPage(
      fromPageIndex,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );

    roomListSave();
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }

  swapRoom(int oldRoomIndex, int newRoomIndex) {
    if (oldRoomIndex == newRoomIndex) {
      log.e('oldRoomIndex==newRoomIndex');
      return;
    }

    log.w('swapRoom oldRoomIndex $oldRoomIndex newRoomIndex $newRoomIndex');

    Room oldRoom = roomList[oldRoomIndex];
    roomList.remove(oldRoom);
    roomList.insert(newRoomIndex, oldRoom);

    pageController.animateToPage(newRoomIndex - 1,
        duration: Duration(milliseconds: 500), curve: Curves.ease);

    roomListSave();
    notifyListeners();
  }

  void roomListSave() {
    try {
      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");
      gd.saveString('roomList $url', jsonEncode(roomList));
      roomListSaveFirebaseTimer(5);
      log.w('roomListSave $url roomList.length ${roomList.length}');
    } catch (e) {
      log.w("roomListSave $e");
    }
  }

  Timer _roomListSaveFirebase;

  void roomListSaveFirebaseTimer(int seconds) {
    _roomListSaveFirebase?.cancel();
    _roomListSaveFirebase = null;

    log.d("roomListSaveFirebase delay");

    _roomListSaveFirebase =
        Timer(Duration(seconds: seconds), roomListSaveFirebase);
  }

  void roomListSaveFirebase() {
    var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
    url = url.replaceAll("/", "-");
    url = url.replaceAll(":", "-");
    if (gd.firebaseUser != null) {
      log.w(
          'roomListSaveFirebase roomListSave $url roomList.length ${roomList.length}');
      Firestore.instance
          .collection('UserData')
          .document('${gd.firebaseUser.uid}')
          .updateData(
        {
          'roomList $url': jsonEncode(roomList),
        },
      );
    }
  }

  String _roomListString;

  String get roomListString => _roomListString;

  set roomListString(val) {
    if (_roomListString != val) {
      _roomListString = val;

      if (_roomListString != null && _roomListString.length > 0) {
        log.w('FOUND _roomListString');
        List<dynamic> roomListJson = jsonDecode(_roomListString);

        roomList.clear();
        roomList = [];

        for (var roomJson in roomListJson) {
          Room room = Room.fromJson(roomJson);
          log.d('addRoom ${room.name}');
          roomList.add(room);
        }
        log.d('loginDataList.length ${roomList.length}');
      }
//      else if(currentUrl)
//        {
//
//        }
      else {
        log.w('CAN NOT FIND roomList adding default data');
//        roomList.clear();
//        roomList = [];
        gd.roomListString = "";
        for (var room in roomListDefault) {
          roomList.add(room);
        }
      }

      notifyListeners();
    }
  }

//  loadRoomListAsync(String url) async {
//    url = base64Url.encode(utf8.encode(url));
//    roomListString = await gd.getString('roomList $url');
//  }

  var emptySliver = SliverFixedExtentList(
    itemExtent: 0,
    delegate: SliverChildListDelegate(
      [],
    ),
  );

  String textToDisplay(String text) {
    text = text.replaceAll('_', ' ');
    if (text.length > 1) {
      return text[0].toUpperCase() + text.substring(1);
    } else if (text.length > 0) {
      return text[0].toUpperCase();
    } else {
      return '???';
    }
  }

  Map<String, String> toggleStatusMap = {};

  void toggleStatus(Entity entity) {
    toggleStatusMap[entity.entityId] = random.nextInt(10).toString();
//    log.d("toggleStatusMap ${toggleStatusMap.values.toList()}");
    if (entity.entityType != EntityType.lightSwitches &&
        entity.entityType != EntityType.scriptAutomation &&
        entity.entityType != EntityType.climateFans &&
        entity.entityType != EntityType.mediaPlayers) {
      return;
    }
    delayGetStatesTimer(5);
    entity.toggleState();
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void setState(Entity entity, String state, String message) {
    toggleStatusMap[entity.entityId] = random.nextInt(10).toString();
//    log.d("toggleStatusMap ${toggleStatusMap.values.toList()}");
    entity.state = state;
    delayGetStatesTimer(5);
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void setFanSpeed(Entity entity, String speed, String message) {
    delayGetStatesTimer(5);
    entity.speed = speed;
    entity.state = "on";
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void setFanOscillating(Entity entity, bool oscillating, String message) {
    delayGetStatesTimer(5);
    entity.oscillating = oscillating;
    webSocket.send(message);
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  Timer _delayGetStates;

  void delayGetStatesTimer(int seconds) {
    _delayGetStates?.cancel();
    _delayGetStates = null;

    _delayGetStates = Timer(Duration(seconds: seconds), delayGetStates);
  }

  void delayGetStates() {
    var outMsg = {'id': gd.socketId, 'type': 'get_states'};
    webSocket.send(json.encode(outMsg));
    gd.connectionStatus = 'Sending get_states';
    log.w('delayGetStates!');
  }

  List<String> get entitiesInRoomsExceptDefault {
    List<String> recVal = [];
    for (int i = 0; i < roomList.length - 2; i++) {
      recVal = recVal + roomList[i].entities;
    }
    return recVal;
  }

  void removeEntityInRoom(String entityId, int roomIndex, String friendlyName,
      BuildContext context) {
    log.w('removeEntityInRoom $entityId roomIndex $roomIndex');
    if (gd.roomList[roomIndex].entities.contains(entityId)) {
      gd.roomList[roomIndex].entities.remove(entityId);
      notifyListeners();
      Flushbar(
//        title: "Require Slide to Open",
        message: "Removed $friendlyName from ${roomList[roomIndex].name}",
        duration: Duration(seconds: 3),
      )..show(context);
      roomListSave();
    }
    delayCancelEditModeTimer(300);
  }

  void showEntityInRoom(String entityId, int roomIndex, String friendlyName,
      BuildContext context) {
    log.w('showEntityInRoom $entityId roomIndex $roomIndex');
    if (!gd.roomList[roomIndex].entities.contains(entityId)) {
      gd.roomList[roomIndex].entities.add(entityId);
      notifyListeners();
      Flushbar(
//        title: "Require Slide to Open",
        message: "Added $friendlyName to ${roomList[roomIndex].name}",
        duration: Duration(seconds: 3),
      )..show(context);
      roomListSave();
    }
    delayCancelEditModeTimer(300);
  }

  IconData climateModeToIcon(String text) {
    text = text.toLowerCase();
    if (text.contains('off')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:power');
    }
    if (text.contains('cool')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:snowflake');
    }
    if (text.contains('heat')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:weather-sunny');
    }
    if (text.contains('fan')) {
      return MaterialDesignIcons.getIconDataFromIconName('mdi:fan');
    }
    return MaterialDesignIcons.getIconDataFromIconName('mdi:thermometer');
  }

  Color climateModeToColor(String text) {
    text = text.toLowerCase();
    if (text.contains('off')) {
      return ThemeInfo.colorBottomSheetReverse.withOpacity(0.75);
    }
    if (text.contains('heat')) {
      return Colors.red;
    }
    if (text.contains('cool')) {
      return Colors.green;
    }
    return Colors.amber;
  }

  ViewMode _viewMode = ViewMode.normal;

  get viewMode => _viewMode;

  set viewMode(ViewMode viewMode) {
    if (viewMode == ViewMode.edit) {
      delayCancelEditModeTimer(300);
    }
    if (viewMode == ViewMode.sort) {
      delayCancelSortModeTimer(300);
    }
    if (_viewMode != viewMode) {
      _viewMode = viewMode;
      notifyListeners();
    }
  }

  Timer _delayCancelSortMode;

  void delayCancelSortModeTimer(int seconds) {
    _delayCancelSortMode?.cancel();
    _delayCancelSortMode = null;

    _delayCancelSortMode =
        Timer(Duration(seconds: seconds), delayCancelSortMode);
  }

  void delayCancelSortMode() {
    viewMode = ViewMode.normal;
    log.w('delayCancelSortMode!');
  }

  void toggleSortMode() {
    if (viewMode == ViewMode.sort) {
      viewMode = ViewMode.normal;
    } else {
      viewMode = ViewMode.sort;
    }
    notifyListeners();
  }

  Timer _delayCancelEditMode;

  void delayCancelEditModeTimer(int seconds) {
    _delayCancelEditMode?.cancel();
    _delayCancelEditMode = null;

    _delayCancelEditMode =
        Timer(Duration(seconds: seconds), delayCancelEditMode);
  }

  void delayCancelEditMode() {
    viewMode = ViewMode.normal;
    log.w('delayCancelEditMode!');
  }

  void toggleEditMode() {
    if (viewMode == ViewMode.edit) {
      viewMode = ViewMode.normal;
    } else {
      viewMode = ViewMode.edit;
    }
    notifyListeners();
  }

  String entityTypeCombined(String entityId) {
    entityId = entityId.split('.').first;
    if (entityId.contains('fan.') || entityId.contains('climate.')) {
      return 'climateFans';
    } else if (entityId.contains('camera.')) {
      return 'cameras';
    } else if (entityId.contains('media_player.')) {
      return 'mediaPlayers';
    } else if (entityId.contains('script.') ||
        entityId.contains('automation.')) {
      return 'scriptAutomation';
    } else if (entityId.contains('light.') ||
        entityId.contains('switch.') ||
        entityId.contains('cover.') ||
        entityId.contains('input_boolean.') ||
        entityId.contains('lock.') ||
        entityId.contains('vacuum.')) {
      return 'lightSwitches';
    } else {
      return 'accessories';
    }
  }

  double mapNumber(
      double x, double inMin, double inMax, double outMin, double outMax) {
    return (x - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
  }

  int colorCap(int x, int inMin, int inMax) {
    if (x < inMin) {
      return inMin;
    }
    if (x > inMax) {
      return inMax;
    }
    return x;
  }

//  List<String> requireSlideToOpen = [];

  void requireSlideToOpenAddRemove(String entityId) {
    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].openRequireAttention != null &&
        gd.entitiesOverride[entityId].openRequireAttention == true) {
      gd.entitiesOverride[entityId].openRequireAttention = false;
    } else {
      var entitiesOverride = gd.entitiesOverride[entityId];
      if (entitiesOverride == null) entitiesOverride = new EntityOverride();
      entitiesOverride.openRequireAttention = true;
      gd.entitiesOverride[entityId] = entitiesOverride;
    }
    notifyListeners();
    entitiesOverrideSave();
  }

  String _baseSettingString;

  String get baseSettingString => _baseSettingString;

  set baseSettingString(val) {
    if (_baseSettingString != val) {
      _baseSettingString = val;

      if (_baseSettingString != null && _baseSettingString.length > 0) {
        log.w('FOUND _baseSettingString $_baseSettingString');
        gd.itemsPerRow = jsonDecode(_baseSettingString)['itemsPerRow'];
        gd.themeIndex = jsonDecode(_baseSettingString)['themeIndex'];
      } else {
        log.w('loadBaseSetting baseSettingString.length == 0');
        gd.itemsPerRow = 3;
        gd.themeIndex = 1;
      }

      notifyListeners();
    }
  }

  void baseSettingSave() {
    try {
      var jsonBaseSetting = {
        'itemsPerRow': gd.itemsPerRow,
        'themeIndex': gd.themeIndex,
      };
      gd.saveString('baseSetting', jsonEncode(jsonBaseSetting));
      log.w('save baseSetting $jsonBaseSetting');
    } catch (e) {
      log.w("baseSettingSave $e");
    }
    notifyListeners();
  }

  Map<String, EntityOverride> entitiesOverride = {};
  String _entitiesOverrideString;

  String get entitiesOverrideString => _entitiesOverrideString;

  set entitiesOverrideString(val) {
    if (_entitiesOverrideString != val) {
      _entitiesOverrideString = val;

      if (_entitiesOverrideString != null &&
          _entitiesOverrideString.length > 0) {
        log.w('FOUND _entitiesOverrideString $_entitiesOverrideString');
        entitiesOverride = {};

        Map<String, dynamic> entitiesOverrideJson =
            jsonDecode(entitiesOverrideString);

        for (var entityOverrideJson in entitiesOverrideJson.keys) {
          var entitiesOverrideId = entityOverrideJson;
          var entitiesOverrideIdList = entitiesOverrideJson[entitiesOverrideId];
          entitiesOverride[entitiesOverrideId] =
              EntityOverride.fromJson(entitiesOverrideIdList);
        }
        log.d('entitiesOverride.length ${entitiesOverride.length}');

        for (int i = 0; i < entitiesOverride.length; i++) {
          log.d("${entitiesOverride[i]}");
        }
      } else {
        log.w('CAN NOT FIND entitiesOverride');
        entitiesOverride = {};
      }

      notifyListeners();
    }
  }

  void entitiesOverrideSave() {
    try {
      Map<String, EntityOverride> entitiesOverrideClean = {};

      for (var key in gd.entitiesOverride.keys) {
        var entityOverrideClean = gd.entitiesOverride[key];
        if (entityOverrideClean.friendlyName != null &&
                entityOverrideClean.friendlyName.length > 0 ||
            entityOverrideClean.icon != null &&
                entityOverrideClean.icon.length > 0 ||
            entityOverrideClean.openRequireAttention != null &&
                entityOverrideClean.openRequireAttention == true) {
          entitiesOverrideClean[key] = entityOverrideClean;
        }
      }
      entitiesOverride = entitiesOverrideClean;
      gd.saveString('entitiesOverride', jsonEncode(entitiesOverride));
      log.w('save entitiesOverride.length ${entitiesOverride.length}');
      entitiesOverrideSaveFirebaseTimer(5);
    } catch (e) {
      log.w("entitiesOverrideSave $e");
    }
    notifyListeners();
  }

  Timer _entitiesOverrideSaveFirebase;

  void entitiesOverrideSaveFirebaseTimer(int seconds) {
    _entitiesOverrideSaveFirebase?.cancel();
    _entitiesOverrideSaveFirebase = null;

    _entitiesOverrideSaveFirebase =
        Timer(Duration(seconds: seconds), entitiesOverrideSaveFirebase);
  }

  void entitiesOverrideSaveFirebase() {
    if (gd.firebaseUser != null) {
      log.w(
          'entitiesOverrideSaveFirebase entitiesOverride.length ${entitiesOverride.length}');
      Firestore.instance
          .collection('UserData')
          .document('${gd.firebaseUser.uid}')
          .updateData(
        {
          'entitiesOverride': jsonEncode(entitiesOverride),
        },
      );
    }
  }

  List<String> iconsOverride = [
    "",
    "mdi:account",
    "mdi:air-conditioner",
    "mdi:air-filter",
    "mdi:air-horn",
    "mdi:air-purifier",
    "mdi:airplay",
    "mdi:alert",
    "mdi:alert-outline",
    "mdi:battery-80",
    "mdi:bell",
    "mdi:blinds",
    "mdi:blur-radial",
    "mdi:brightness-5",
    "mdi:brightness-7",
    "mdi:camera",
    "mdi:candle",
    "mdi:cast",
    "mdi:ceiling-light",
    "mdi:check-outline",
    "mdi:checkbox-blank-circle-outline",
    "mdi:checkbox-marked-circle",
    "mdi:desk-lamp",
    "mdi:dip-switch",
    "mdi:doorbell-video",
    "mdi:door-closed",
    "mdi:fan",
    "mdi:fire",
    "mdi:flash",
    "mdi:floor-lamp",
    "mdi:flower",
    "mdi:garage",
    "mdi:gauge",
    "mdi:group",
    "mdi:home",
    "mdi:home-automation",
    "mdi:home-outline",
    "mdi:lamp",
    "mdi:lava-lamp",
    "mdi:leaf",
    "mdi:light-switch",
    "mdi:lightbulb",
    "mdi:lightbulb-off",
    "mdi:lightbulb-off-outline",
    "mdi:lightbulb-outline",
    "mdi:lighthouse",
    "mdi:lighthouse-on",
    "mdi:lock",
    "mdi:music-note",
    "mdi:music-note-off",
    "mdi:page-layout-sidebar-right",
    "mdi:power",
    "mdi:power-cycle",
    "mdi:power-off",
    "mdi:power-on",
    "mdi:power-plug",
    "mdi:power-plug-off",
    "mdi:power-settings",
    "mdi:power-sleep",
    "mdi:power-socket",
    "mdi:power-socket-au",
    "mdi:power-socket-eu",
    "mdi:power-socket-uk",
    "mdi:power-socket-us",
    "mdi:power-standby",
    "mdi:radiator",
    "mdi:robot-vacuum",
    "mdi:script-text",
    "mdi:server-network",
    "mdi:server-network-off",
    "mdi:shield-check",
    "mdi:snowflake",
    "mdi:speaker",
    "mdi:square",
    "mdi:square-outline",
    "mdi:theater",
    "mdi:thermometer",
    "mdi:thermostat",
    "mdi:timer",
    "mdi:toggle-switch",
    "mdi:toggle-switch-off",
    "mdi:toggle-switch-off-outline",
    "mdi:toggle-switch-outline",
    "mdi:track-light",
    "mdi:vibrate",
    "mdi:video-switch",
    "mdi:walk",
    "mdi:wall-sconce",
    "mdi:wall-sconce-flat",
    "mdi:wall-sconce-variant",
    "mdi:water",
    "mdi:water-off",
    "mdi:water-percent",
    "mdi:weather-partlycloudy",
    "mdi:webcam",
    "mdi:white-balance-incandescent",
    "mdi:white-balance-iridescent",
    "mdi:white-balance-sunny",
    "mdi:window-closed",
  ];

  IconData mdiIcon(String iconString) {
    try {
      return MaterialDesignIcons.getIconDataFromIconName(iconString);
    } catch (e) {
      log.e("mdiIcon $e");
      return MaterialDesignIcons.getIconDataFromIconName("help-box");
    }
  }

  String getNulString(String input) {
    try {
      return input;
    } catch (e) {
      return "";
    }
  }

  int getNullInt(int input) {
    if (input == null) {
      return 0;
    }
    return input;
  }

  AppLifecycleState _lastLifecycleState;

  AppLifecycleState get lastLifecycleState => _lastLifecycleState;

  set lastLifecycleState(AppLifecycleState val) {
    if (_lastLifecycleState != val) {
      _lastLifecycleState = val;
      notifyListeners();
    }
  }

  FirebaseUser _firebaseUser;
  FirebaseUser get firebaseUser => _firebaseUser;
  set firebaseUser(FirebaseUser val) {
    if (_firebaseUser != val) {
      _firebaseUser = val;

      if (_firebaseUser != null) {
        log.d(
            "_firebaseUser uid ${_firebaseUser.uid} email ${_firebaseUser.email} "
            "photoUrl ${_firebaseUser.photoUrl} phoneNumber ${_firebaseUser.phoneNumber} displayName ${_firebaseUser.displayName}");

        Firestore.instance
            .collection('UserData')
            .document('${gd.firebaseUser.uid}')
            .get()
            .then(
          (DocumentSnapshot ds) {
            // use ds as a snapshot
//            log.d("ds.exists ${ds.exists}");
            if (!ds.exists) {
              Firestore.instance
                  .collection('UserData')
                  .document('${gd.firebaseUser.uid}')
                  .setData(
                {
                  'created': DateTime.now(),
                },
              );
            }
          },
        );
        getSettings("_firebaseUser != null");
        getStreamData();
      }
      log.e("firebaseUser notifyListeners");
      notifyListeners();
    }
  }

  Future<void> assignFirebaseUser(
      GoogleSignInAccount googleSignInAccount) async {
    try {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final AuthResult authResult =
          await FirebaseAuth.instance.signInWithCredential(credential);
      gd.firebaseUser = authResult.user;
    } catch (error) {
      print(error);
    }
  }

  GoogleSignInAccount _googleSignInAccount;
  GoogleSignInAccount get googleSignInAccount => _googleSignInAccount;

  set googleSignInAccount(GoogleSignInAccount googleSignInAccount) {
    if (_googleSignInAccount != googleSignInAccount) {
      _googleSignInAccount = googleSignInAccount;
      log.w("_firebaseCurrentUser != firebaseCurrentUser");

      if (googleSignInAccount != null) {
        log.w("get the FirebaseUser");
        assignFirebaseUser(googleSignInAccount);
      } else {
        firebaseUser = null;
      }
      log.e("googleSignInAccount notifyListeners");
      notifyListeners();
    }
  }

  Stream<DocumentSnapshot> snapshots;

  getStreamData() async {
    if (firebaseUser != null) {
      gd.snapshots = Firestore.instance
          .collection('UserData')
          .document("${firebaseUser.uid}")
          .snapshots();

      if (gd.snapshots != null) {
        await for (var documents in gd.snapshots) {
          if (firebaseUser != null && documents.data != null) {
            log.d("NEW streamData ${documents.data.length}");
            gd.entitiesOverrideString = "";
            gd.entitiesOverrideString = documents.data["entitiesOverride"];
            gd.roomListString = "";
            var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
            url = url.replaceAll("/", "-");
            url = url.replaceAll(":", "-");
            gd.roomListString = documents.data["roomList $url"];
          }
        }
      }
    } else {
      gd.snapshots = null;
    }
  }

  getSettings(String reason) async {
    log.e("getSettings FROM $reason");
    //NO URL return empty data

    if (loginDataList.length < 1) {
      loginDataList.add(loginDataHassKitDemo);
      loginDataCurrent = loginDataHassKitDemo;
    }

    if (!gd.autoConnect ||
        gd.currentUrl == "" ||
        gd.loginDataCurrent.url == null ||
        !isURL(gd.loginDataCurrent.url, protocols: ['http', 'https'])) {
      log.e("getSettings gd.autoConnect");
      gd.roomList = [];
      gd.entitiesOverride = {};
      return;
    }

    //force the trigger reset
    gd.baseSettingString = "";
    gd.baseSettingString = await gd.getString('baseSetting');

    //no firebase return load disk data
    if (gd.firebaseUser == null) {
      log.e("gd.firebaseUser == null");
      //force the trigger reset
      gd.entitiesOverrideString = "";
      gd.entitiesOverrideString = await gd.getString('entitiesOverride');
      //force the trigger reset
      gd.roomListString = "";
      var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
      url = url.replaceAll("/", "-");
      url = url.replaceAll(":", "-");
      gd.roomListString = await gd.getString('roomList $url');
      if (gd.roomListString == null || gd.roomListString.length < 1) {
        if (gd.currentUrl == "http://hasskitdemo.duckdns.org:8123") {
          gd.roomListString = json.encode(gd.roomListHassKitDemo);
        } else {
          gd.roomListString = json.encode(gd.roomListDefault);
        }
      }
      return;
    }

    log.e("gd.firebaseCurrentUser != null");

    Firestore.instance
        .collection('UserData')
        .document('${gd.firebaseUser.uid}')
        .get()
        .then(
      (DocumentSnapshot ds) {
        log.e("gd.firebaseCurrentUser != null ds.exists");
        //force the trigger reset
//        gd.baseSettingString = "";
//        gd.baseSettingString = ds["baseSetting"];
        //force the trigger reset
        gd.entitiesOverrideString = "";
        gd.entitiesOverrideString = ds["entitiesOverride"];
        //force the trigger reset
        gd.roomListString = "";
        var url = gd.loginDataCurrent.getUrl.replaceAll(".", "-");
        url = url.replaceAll("/", "-");
        url = url.replaceAll(":", "-");
        gd.roomListString = ds['roomList $url'];

        if (gd.roomListString == null || gd.roomListString.length < 1) {
          if (gd.currentUrl == "http://hasskitdemo.duckdns.org:8123") {
            gd.roomListString = json.encode(gd.roomListHassKitDemo);
          } else {
            gd.roomListString = json.encode(gd.roomListDefault);
          }
        }
      },
    );
  }

  String _currentUrl = "";
  String get currentUrl => _currentUrl;
  set currentUrl(String val) {
    if (val != _currentUrl) {
      _currentUrl = val;
      if (_currentUrl != "") {
        getSettings("currentUrl");
      }
      notifyListeners();
    }
  }

  int _cameraStreamId = 0;

  int get cameraStreamId => _cameraStreamId;

  set cameraStreamId(int val) {
    if (val == null) {
      throw new ArgumentError();
    }
    if (_cameraStreamId != val) {
      _cameraStreamId = val;
      notifyListeners();
    }
  }

  String _cameraStreamUrl = "";

  String get cameraStreamUrl => _cameraStreamUrl;

  set cameraStreamUrl(String val) {
    if (_cameraStreamUrl != val) {
      _cameraStreamUrl = val;
      notifyListeners();
    }
  }

  void requestCameraStream(String entityId) {
    try {
      if (gd.cameraStreamId == 0 && gd.cameraStreamUrl == "") {
        gd.cameraStreamId = gd.socketId;
        var outMsg = {
          "id": gd.cameraStreamId,
          "type": "camera/stream",
          "format": "hls",
          "entity_id": entityId,
        };

        webSocket.send(jsonEncode(outMsg));
        log.d("requestCameraStream ${jsonEncode(outMsg)}");
      }
    } catch (e) {
      log.e("requestCameraStream $entityId $e");
    }
  }
}
