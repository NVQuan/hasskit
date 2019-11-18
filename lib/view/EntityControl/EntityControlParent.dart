import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:hasskit/model/EntityOverride.dart';
import 'package:hasskit/view/EntityControl/EntityControlClimate.dart';
import 'package:hasskit/view/EntityControl/EntityControlGeneral.dart';
import 'package:provider/provider.dart';

import 'EntityControlFan.dart';
import 'EntityControlLightDimmer.dart';
import 'EntityControlToggle.dart';

class EntityControlParent extends StatefulWidget {
  final String entityId;
  const EntityControlParent({@required this.entityId});

  @override
  _EntityControlParentState createState() => _EntityControlParentState();
}

class _EntityControlParentState extends State<EntityControlParent> {
  bool showEditName = false;
  bool showIconSelection = false;
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = '${gd.entities[widget.entityId].getOverrideName}';
  }

  @override
  Widget build(BuildContext context) {
//    log.w('Widget build EntityEditPage');

    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
//          "${generalData.toggleStatusMap[widget.entityId]} " +
          "${generalData.entities[widget.entityId].state} " +
          "${generalData.entities[widget.entityId].getFriendlyName} " +
          "${generalData.entities[widget.entityId].getOverrideIcon} " +
          "${jsonEncode(generalData.entitiesOverride[widget.entityId])} ",
      builder: (context, data, child) {
        final Entity entity = gd.entities[widget.entityId];
        if (entity == null) {
          log.e('Cant find entity name ${widget.entityId}');
          return Container();
        }

        Widget entityControl;

        if (entity.entityType == EntityType.climateFans &&
            entity.hvacModes != null &&
            entity.hvacModes.length > 0) {
          entityControl = EntityControlClimate(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.climateFans &&
            entity.speedList != null &&
            entity.speedList.length > 0) {
          entityControl = EntityControlFan(entityId: widget.entityId);
        } else if (entity.entityId.contains("light.") &&
            (entity.getSupportedFeaturesLights.contains("SUPPORT_RGB_COLOR") ||
                entity.getSupportedFeaturesLights
                    .contains("SUPPORT_COLOR_TEMP") ||
                entity.getSupportedFeaturesLights
                    .contains("SUPPORT_BRIGHTNESS"))) {
          entityControl = EntityControlLightDimmer(entityId: widget.entityId);
        } else if (entity.entityType == EntityType.lightSwitches ||
            entity.entityType == EntityType.mediaPlayers ||
            entity.entityId.contains("group.")) {
          entityControl = EntityControlToggle(entityId: widget.entityId);
        } else {
          entityControl = EntityControlGeneral(entityId: widget.entityId);
        }
//    return Selector<GeneralData, String>(
//      selector: (_, generalData) =>
//          "${generalData.connectionStatus} " +
//          "${generalData.entities[widget.entityId].state}",
//      builder: (_, state, __) {
        return SafeArea(
          child: Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 8, right: 8),
                color: ThemeInfo.colorBottomSheet,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: Container(),
                    ),

                    !showEditName
                        ? Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(left: 40, right: 40),
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  entity.entityId,
//                                  gd.textToDisplay(entity.getOverrideName),
                                  style: Theme.of(context).textTheme.title,
                                  textScaleFactor: gd.textScaleFactor,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: InkWell(
                                    onTap: () {
                                      showEditName = true;
                                      setState(() {});
                                    },
                                    child: Container(
                                      child: Icon(
                                        Icons.edit,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: TextField(
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.zero,
                                      hintText:
                                          '${gd.entities[widget.entityId].getFriendlyName}'),
                                  focusNode: _focusNode,
                                  controller: _controller,
                                  style: Theme.of(context).textTheme.title,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  autocorrect: false,
                                  autofocus: true,
                                  onEditingComplete: () {
                                    showEditName = false;
                                    setState(
                                      () {
                                        if (gd.entitiesOverride[
                                                widget.entityId] !=
                                            null) {
                                          gd.entitiesOverride[widget.entityId]
                                                  .friendlyName =
                                              _controller.text.trim();
                                        } else {
                                          gd.entitiesOverride[widget.entityId] =
                                              EntityOverride(
                                                  friendlyName:
                                                      _controller.text.trim());
                                        }
                                        gd.entitiesOverrideSave();
                                      },
                                    );
                                  },
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                alignment: Alignment.centerRight,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: InkWell(
                                    onTap: () {
                                      showEditName = false;

                                      if (gd.entitiesOverride[
                                              widget.entityId] !=
                                          null) {
                                        gd.entitiesOverride[widget.entityId]
                                                .friendlyName =
                                            _controller.text.trim();
                                      } else {
                                        gd.entitiesOverride[widget.entityId] =
                                            EntityOverride(
                                                friendlyName:
                                                    _controller.text.trim());
                                      }
                                      gd.entitiesOverrideSave();
                                      setState(
                                        () {},
                                      );
                                    },
                                    child: Container(
                                      child: Icon(
                                        Icons.save,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    !showIconSelection
                        ? Stack(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.topRight,
                                width: double.infinity,
                                child: SizedBox(
                                  width: 40,
                                  height: 40,
                                  child: InkWell(
                                    onTap: () {
                                      showIconSelection = true;
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode());
                                      setState(() {});
                                    },
                                    child: Container(
                                      child: Icon(
                                        Icons.edit,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: entityControl,
                              ),
                            ],
                          )
                        : Stack(
                            children: <Widget>[
                              _IconSelection(
                                entityId: widget.entityId,
                                closeIconSelection: () {
                                  showIconSelection = false;
                                  FocusScope.of(context)
                                      .requestFocus(new FocusNode());
                                  setState(() {});
                                },
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                width: double.infinity,
                                child: InkWell(
                                  onTap: () {
                                    showIconSelection = false;
                                    setState(() {});
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.cancel,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                    SizedBox(height: 16),
                    Expanded(
                      child: Container(),
                    ),
//                  SizedBox(height: 40),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                right: 40,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.cancel,
                    color: ThemeInfo.colorBottomSheetReverse,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IconSelection extends StatefulWidget {
  final String entityId;
  final Function closeIconSelection;
  const _IconSelection(
      {@required this.entityId, @required this.closeIconSelection});

  @override
  __IconSelectionState createState() => __IconSelectionState();
}

class __IconSelectionState extends State<_IconSelection> {
  @override
//  void initState() {
//    super.initState();
//    gd.iconsOverride.sort((a, b) => a.compareTo(b));
//
//    var recval = "";
//    for (var name in gd.iconsOverride) {
//      recval = recval + ("\"$name\",");
//    }
//
//    printWrapped(recval);
//  }
//
//  void printWrapped(String text) {
//    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
//    pattern.allMatches(text).forEach((match) => print(match.group(0)));
//  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              color: ThemeInfo.colorIconActive),
          child: Center(
            child: Text(
              "Select Custom Icon",
              style: Theme.of(context).textTheme.title,
              overflow: TextOverflow.ellipsis,
              textScaleFactor: gd.textScaleFactor,
            ),
          ),
        ),
        Container(
          height: 316,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
              color: ThemeInfo.colorBottomSheetReverse.withOpacity(0.25)),
          child: CustomScrollView(
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 80.0,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return InkWell(
                        onTap: () {
                          if (gd.entitiesOverride[widget.entityId] != null) {
                            gd.entitiesOverride[widget.entityId].icon =
                                gd.iconsOverride[index];
                          } else {
                            EntityOverride entityOverride =
                                EntityOverride(icon: gd.iconsOverride[index]);
                            gd.entitiesOverride[widget.entityId] =
                                entityOverride;
                          }
                          gd.entitiesOverrideSave();
                          widget.closeIconSelection();
//                          setState(() {
//                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color:
                                  ThemeInfo.colorBottomSheet.withOpacity(0.25)),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              index == 0
                                  ? Text(
                                      "Reset Icon",
                                      style: ThemeInfo.textStatusButtonInActive
                                          .copyWith(
                                              color: ThemeInfo
                                                  .colorBottomSheetReverse
                                                  .withOpacity(0.75)),
                                      textScaleFactor: gd.textScaleFactor,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                    )
                                  : Icon(
                                      gd.mdiIcon(gd.iconsOverride[index]),
                                      size: 50,
                                      color: ThemeInfo.colorBottomSheetReverse
                                          .withOpacity(0.75),
                                    ),
//                              Text(
//                                gd.iconsOverride[index],
//                                textScaleFactor: 0.5,
//                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: gd.iconsOverride.length,
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
