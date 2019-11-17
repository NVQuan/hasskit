import 'package:flutter/material.dart';

class Room {
  String name;
  int imageIndex;
  String tempEntityId;
  String humidEntityId;
  List<String> favorites;
  List<String> entities;
  List<String> row3;
  List<String> row4;

  Room(
      {@required this.name,
      @required this.imageIndex,
      this.tempEntityId = "",
      this.humidEntityId = "",
      this.entities,
      this.favorites,
      this.row3,
      this.row4});

  Map<String, dynamic> toJson() => {
        'name': name,
        'imageIndex': imageIndex,
        'tempEntityId': tempEntityId,
        'humidEntityId': humidEntityId,
        'favorites': favorites,
        'entities': entities,
        'row3': row3,
        'row4': row4,
      };

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      name: json['name'],
      imageIndex: json['imageIndex'],
      tempEntityId: json['tempEntityId'] != null ? json['tempEntityId'] : "",
      humidEntityId: json['humidEntityId'] != null ? json['humidEntityId'] : "",
      favorites:
          json['favorites'] != null ? List<String>.from(json['favorites']) : [],
      entities:
          json['entities'] != null ? List<String>.from(json['entities']) : [],
      row3: json['row3'] != null ? List<String>.from(json['row3']) : [],
      row4: json['row4'] != null ? List<String>.from(json['row4']) : [],
    );
  }
}
