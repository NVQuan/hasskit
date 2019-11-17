import 'package:flutter/material.dart';
import 'package:hasskit/helper/Logger.dart';

class BaseSetting {
  int itemsPerRow;
  int themeIndex;

  BaseSetting({
    @required this.itemsPerRow,
    @required this.themeIndex,
  });

  Map<String, dynamic> toJson() => {
        'itemsPerRow': itemsPerRow,
        'themeIndex': themeIndex,
      };

  factory BaseSetting.fromJson(Map<String, dynamic> json) {
    try {
      return BaseSetting(
        itemsPerRow: json['itemsPerRow'] != null ? json['itemsPerRow'] : 3,
        themeIndex: json['themeIndex'] != null ? json['themeIndex'] : 1,
      );
    } catch (e) {
      log.e("BaseSetting.fromJson $e");
      return null;
    }
  }
}
