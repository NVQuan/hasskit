import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/view/slivers/SliverEntities.dart';
import 'package:hasskit/view/slivers/SliverNavigationBar.dart';
import 'package:hasskit/view/CustomScrollView/ViewNormal.dart';

import 'DeviceTypeHeader.dart';

class ViewSort extends StatelessWidget {
  final int roomIndex;
  const ViewSort({@required this.roomIndex});

  @override
  Widget build(BuildContext context) {
    var row1 = entityFilterByRow(roomIndex, 1, false);
    var row1Cam = entityFilterByRow(roomIndex, 1, true);
    var row2 = entityFilterByRow(roomIndex, 2, false);
    var row2Cam = entityFilterByRow(roomIndex, 2, true);
    var row3 = entityFilterByRow(roomIndex, 3, false);
    var row3Cam = entityFilterByRow(roomIndex, 3, true);
    var row4 = entityFilterByRow(roomIndex, 4, false);
    var row4Cam = entityFilterByRow(roomIndex, 4, true);

//    return Selector<GeneralData, String>(
//      selector: (_, generalData) =>
//          "${generalData.connectionStatus} |" +
//          "${generalData.roomList[roomIndex].entities.toList()} |" +
//          "${generalData.roomList[roomIndex].favorites.toList()} |",
//      builder: (context, data, child) {
    return CustomScrollView(
      slivers: [
        SliverNavigationBar(roomIndex: roomIndex),
        row1.length + row1Cam.length > 0
            ? DeviceTypeHeaderEditNormal(icon: Icon(Icons.looks_one), title: '')
            : gd.emptySliver,
        row1.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: gd.itemsPerRow,
                entities: row1,
                rowNumber: 1,
              )
            : gd.emptySliver,
        row1Cam.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: 1,
                entities: row1Cam,
                rowNumber: 1,
              )
            : gd.emptySliver,
        row2.length + row2Cam.length > 0
            ? DeviceTypeHeaderEditNormal(icon: Icon(Icons.looks_two), title: '')
            : gd.emptySliver,
        row2.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: gd.itemsPerRow,
                entities: row2,
                rowNumber: 2,
              )
            : gd.emptySliver,
        row2Cam.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: 1,
                entities: row2Cam,
                rowNumber: 2,
              )
            : gd.emptySliver,
        row3.length + row3Cam.length > 0
            ? DeviceTypeHeaderEditNormal(icon: Icon(Icons.looks_3), title: '')
            : gd.emptySliver,
        row3.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: gd.itemsPerRow,
                entities: row3,
                rowNumber: 3,
              )
            : gd.emptySliver,
        row3Cam.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: 1,
                entities: row3Cam,
                rowNumber: 3,
              )
            : gd.emptySliver,
        row4.length + row4Cam.length > 0
            ? DeviceTypeHeaderEditNormal(icon: Icon(Icons.looks_4), title: '')
            : gd.emptySliver,
        row4.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: gd.itemsPerRow,
                entities: row4,
                rowNumber: 4,
              )
            : gd.emptySliver,
        row4Cam.length > 0
            ? SliverEntitiesSort(
                roomIndex: roomIndex,
                itemPerRow: 1,
                entities: row4Cam,
                rowNumber: 4,
              )
            : gd.emptySliver,
        SliverSafeArea(sliver: gd.emptySliver),
      ],
    );
//      },
//    );
  }

  List<Entity> entityFilter(int roomIndex, List<EntityType> types) {
    List<String> roomEntities = gd.roomList[roomIndex].entities;
    List<Entity> entitiesFilter = [];

    for (String entityId in roomEntities) {
      var entity = gd.entities[entityId];
      if (entity != null && types.contains(entity.entityType)) {
        entitiesFilter.add(entity);
      }
    }

    return entitiesFilter;
  }

  List<Entity> entityFrontRow(int roomIndex) {
    //prevent old data fuck up
    if (gd.roomList[roomIndex].favorites == null) {
      gd.roomList[roomIndex].favorites = [];
    }
    List<String> frontRowEntities = gd.roomList[roomIndex].favorites;
    List<Entity> entitiesFilter = [];

    for (String entityId in frontRowEntities) {
      var entity = gd.entities[entityId];
      if (entity != null && entity.entityType != EntityType.cameras) {
        entitiesFilter.add(entity);
      }
    }

    return entitiesFilter;
  }

  List<Entity> entityFrontRowCamera(int roomIndex) {
    //prevent old data fuck up
    if (gd.roomList[roomIndex].favorites == null) {
      gd.roomList[roomIndex].favorites = [];
    }
    List<String> frontRowEntities = gd.roomList[roomIndex].favorites;
    List<Entity> entitiesFilter = [];

    for (String entityId in frontRowEntities) {
      var entity = gd.entities[entityId];
      if (entity != null && entity.entityType == EntityType.cameras) {
        entitiesFilter.add(entity);
      }
    }

    return entitiesFilter;
  }
}
