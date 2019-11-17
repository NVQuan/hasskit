import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CameraThumbnail {
  String entityId;
  DateTime receivedDateTime;
  ImageProvider image;

  CameraThumbnail({
    this.entityId,
    this.receivedDateTime,
    this.image,
  });

  DateTime get getReceivedDateTime {
    if (receivedDateTime != null) return receivedDateTime;
    return DateTime.now().subtract(Duration(days: 1));
  }

  void thumbnailUpdate(Uint8List content) {
    receivedDateTime = DateTime.now();
    image = MemoryImage(content);
  }
}
