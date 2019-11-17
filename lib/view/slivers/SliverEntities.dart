import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/view/EntityControl/EntityControlCamera.dart';
import 'package:reorderables/reorderables.dart';

import '../EntityControl/EntityControlParent.dart';
import '../EntityRectangle.dart';
import '../EntitySquare.dart';

class SliverEntitiesNormal extends StatelessWidget {
  final int roomIndex;
  final int itemPerRow;
  final List<Entity> entities;

  const SliverEntitiesNormal({
    @required this.roomIndex,
    @required this.itemPerRow,
    @required this.entities,
  });
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemPerRow,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: itemPerRow <= 2 ? 8 / 5.5 : 8 / 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return itemPerRow <= 2
                ? EntityRectangle(
                    entityId: entities[index].entityId,
                    borderColor: Colors.transparent,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onTapCallback");
                      gd.cameraStreamUrl = "";
                      gd.cameraStreamId = 0;
                      gd.requestCameraStream(entities[index].entityId);

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return EntityControlCamera(
                              entityId: entities[index].entityId);
                        },
                      );
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onTapCallback");
                      gd.cameraStreamUrl = "";
                      gd.cameraStreamId = 0;
                      gd.requestCameraStream(entities[index].entityId);

                      showModalBottomSheet(
                        context: context,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return EntityControlCamera(
                              entityId: entities[index].entityId);
                        },
                      );
                    },
                  )
                : EntitySquare(
                    entityId: entities[index].entityId,
                    borderColor: Colors.transparent,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onTapCallback");

                      if (entities[index].entityType ==
                              EntityType.accessories ||
                          entities[index].entityType == EntityType.cameras ||
                          !entities[index].isStateOn &&
                              gd.entitiesOverride[entities[index].entityId] !=
                                  null &&
                              gd.entitiesOverride[entities[index].entityId]
                                      .openRequireAttention !=
                                  null &&
                              gd.entitiesOverride[entities[index].entityId]
                                      .openRequireAttention ==
                                  true ||
                          entities[index].entityId.contains('lock.') &&
                              !entities[index].isStateOn) {
                        showModalBottomSheet(
                          context: context,
                          elevation: 1,
                          backgroundColor: ThemeInfo.colorBottomSheet,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (BuildContext context) {
                            return EntityControlParent(
                                entityId: entities[index].entityId);
                          },
                        );
                      } else {
                        gd.toggleStatus(entities[index]);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesNormal onLongPressCallback");
                      showModalBottomSheet(
                        context: context,
                        elevation: 1,
                        backgroundColor: ThemeInfo.colorBottomSheet,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        builder: (BuildContext context) {
                          return EntityControlParent(
                              entityId: entities[index].entityId);
                        },
                      );
                    },
                    indicatorIcon: "SliverEntitiesNormal",
                  );
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}

class SliverEntitiesEdit extends StatelessWidget {
  final int roomIndex;
  final int itemPerRow;
  final List<Entity> entities;
  final bool clickToAdd;
  final Color borderColor;

  const SliverEntitiesEdit({
    @required this.roomIndex,
    @required this.itemPerRow,
    @required this.clickToAdd,
    @required this.entities,
    @required this.borderColor,
  });
  @override
  Widget build(BuildContext context) {
    if (entities.length < 1) {
      return gd.emptySliver;
    }
    return SliverPadding(
      padding: EdgeInsets.all(12),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: itemPerRow,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: itemPerRow == 1 ? 8 / 5 : 8 / 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return itemPerRow == 1
                ? EntityRectangle(
                    entityId: entities[index].entityId,
                    borderColor: borderColor,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onTapCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(
                            entities[index].entityId,
                            roomIndex,
                            entities[index].getOverrideName,
                            context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].getOverrideName, context);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onLongPressCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(
                            entities[index].entityId,
                            roomIndex,
                            entities[index].getOverrideName,
                            context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].getOverrideName, context);
                      }
                    },
                  )
                : EntitySquare(
                    entityId: entities[index].entityId,
                    borderColor: borderColor,
                    onTapCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onTapCallback");

                      if (!clickToAdd) {
                        gd.removeEntityInRoom(entities[index].entityId,
                            roomIndex, entities[index].friendlyName, context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].friendlyName, context);
                      }
                    },
                    onLongPressCallback: () {
                      log.d(
                          "${entities[index].entityId} SliverEntitiesEdit onLongPressCallback");
                      if (!clickToAdd) {
                        gd.removeEntityInRoom(entities[index].entityId,
                            roomIndex, entities[index].friendlyName, context);
                      } else {
                        gd.showEntityInRoom(entities[index].entityId, roomIndex,
                            entities[index].friendlyName, context);
                      }
                    },
                    indicatorIcon: "SliverEntitiesEdit+$clickToAdd",
                  );
          },
          childCount: entities.length,
        ),
      ),
    );
  }
}

class SliverEntitiesSort extends StatelessWidget {
  final int roomIndex;
  final int rowNumber;
  final int itemPerRow;
  final List<Entity> entities;

  const SliverEntitiesSort({
    @required this.roomIndex,
    @required this.rowNumber,
    @required this.itemPerRow,
    @required this.entities,
  });

  @override
  Widget build(BuildContext context) {
    if (entities.length < 2) {
      return SliverEntitiesNormal(
        roomIndex: roomIndex,
        entities: entities,
        itemPerRow: itemPerRow,
      );
    }

    double spacing = 8;
    double edge = 8;

    var width = (gd.mediaQueryWidth - (edge * 2 + spacing * itemPerRow - 1)) /
        itemPerRow;
    List<Widget> entityShape = [];

    for (Entity entity in entities) {
      Widget widget = new Transform.scale(
        scale: 1,
        child: Container(
          width: width,
          height: itemPerRow == 1 ? width / 8 * 5 : width,
          child: itemPerRow == 1
              ? EntityRectangle(
                  entityId: entity.entityId,
                  borderColor: ThemeInfo.colorIconActive,
                  onTapCallback: null,
                  onLongPressCallback: null)
              : EntitySquare(
                  entityId: entity.entityId,
                  borderColor: ThemeInfo.colorIconActive,
                  onTapCallback: null,
                  onLongPressCallback: null,
                  indicatorIcon: "SliverEntitiesSort",
                ),
        ),
      );
      entityShape.add(widget);
    }

    void _onReorder(int oldIndex, int newIndex) {
      String oldEntityId = entities[oldIndex].entityId;
      String newEntityId = entities[newIndex].entityId;
      gd.roomEntitySort(roomIndex, rowNumber, oldEntityId, newEntityId);
    }

    var wrap = ReorderableWrap(
      needsLongPressDraggable: false,
      spacing: spacing,
      runSpacing: spacing,
      padding: const EdgeInsets.all(0),
      children: entityShape,
      onReorder: _onReorder,
      onNoReorder: (int index) {
        //this callback is optional
        log.w("reorder cancelled. index: $index");
      },
      onReorderStarted: (int index) {
        //this callback is optional
        log.w("reorder started. index: $index");
        gd.delayCancelSortModeTimer(300);
      },
    );

    var wrapCentered = Center(
      child: wrap,
    );

    return SliverPadding(
      padding: EdgeInsets.all(edge),
      sliver: SliverList(
        delegate: SliverChildListDelegate([wrapCentered]),
      ),
    );
  }
}
