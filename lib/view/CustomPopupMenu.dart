import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';

BottomSheetMenu bottomSheetMenu = new BottomSheetMenu();

class BottomSheetMenu {
  mainBottomSheet(int roomIndex, BuildContext context) {
    bool showSort = false;
    List<String> classIds = [];
    for (String entityId in gd.roomList[roomIndex].favorites) {
      if (!classIds.contains(gd.entityTypeCombined(entityId))) {
        classIds.add(gd.entityTypeCombined(entityId));
      } else {
        showSort = true;
        break;
      }
    }

    if (!showSort) {
      classIds.clear();
      for (String entityId in gd.roomList[roomIndex].entities) {
        if (!classIds.contains(gd.entityTypeCombined(entityId))) {
          classIds.add(gd.entityTypeCombined(entityId));
        } else {
          showSort = true;
          break;
        }
      }
    }

    log.d(
        "BottomSheetMenu roomIndex $roomIndex gd.roomList.length ${gd.roomList.length}");
    bool showMoveLeft = false;
    if (roomIndex > 1 && roomIndex < gd.roomList.length) {
      showMoveLeft = true;
    }

    bool showMoveRight = false;
    if (roomIndex > 0 && roomIndex != gd.roomList.length - 1) {
      showMoveRight = true;
    }
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: ThemeInfo.colorBottomSheet,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _createTile(
                      context,
                      roomIndex,
                      'Edit ${gd.roomList[roomIndex].name}',
                      MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:view-dashboard-variant"),
                      true,
                      editRoom),
                  _createTile(
                      context,
                      roomIndex,
                      'Arrange ${gd.roomList[roomIndex].name} Devices',
                      MaterialDesignIcons.getIconDataFromIconName(
                          "mdi:cursor-move"),
                      showSort,
                      sortRoom),
                  _createTile(
                      context,
                      roomIndex,
                      'Move ${gd.roomList[roomIndex].name} Left',
                      Icons.chevron_left,
                      showMoveLeft,
                      moveLeft),
                  _createTile(
                      context,
                      roomIndex,
                      'Move ${gd.roomList[roomIndex].name} Right',
                      Icons.chevron_right,
                      showMoveRight,
                      moveRight),
                  _createTile(context, roomIndex, 'Add New Room', Icons.add_box,
                      roomIndex != 0, addNewRoom),
                  _createTile(
                      context,
                      roomIndex,
                      'Delete ${gd.roomList[roomIndex].name}',
                      Icons.delete,
                      roomIndex != 0 && roomIndex != 1,
                      deleteRoom),
                ],
              ),
            ),
          );
        });
  }

  ListTile _createTile(BuildContext context, int roomIndex, String name,
      IconData icon, bool enabled, Function action) {
    return ListTile(
      leading: Opacity(opacity: enabled ? 1 : 0.2, child: Icon(icon)),
      title: Opacity(opacity: enabled ? 1 : 0.2, child: Text(name)),
      onTap: enabled
          ? () {
              Navigator.pop(context);
              action(roomIndex);
            }
          : () {},
    );
  }

  addNewRoom(int roomIndex) {
    log.d('addNewRoom $roomIndex');
    gd.addRoom(roomIndex);
    gd.viewMode = ViewMode.normal;
  }

  editRoom(int roomIndex) {
    log.d('editRoom $roomIndex');
    gd.viewMode = ViewMode.edit;
  }

  deleteRoom(int roomIndex) {
    log.d('deleteRoom $roomIndex');
    gd.deleteRoom(roomIndex);
    gd.viewMode = ViewMode.normal;
  }

  sortRoom(int roomIndex) {
    log.d('sortRoom $roomIndex');
    gd.viewMode = ViewMode.sort;
  }

  moveLeft(int roomIndex) {
    log.d('moveLeft $roomIndex');
    gd.viewMode = ViewMode.normal;
    gd.swapRoom(roomIndex, roomIndex - 1);
  }

  moveRight(int roomIndex) {
    log.d('moveRight $roomIndex');
    gd.viewMode = ViewMode.normal;
    gd.swapRoom(roomIndex, roomIndex + 1);
  }
}
