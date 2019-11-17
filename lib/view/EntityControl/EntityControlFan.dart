import 'dart:convert';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';

class EntityControlFan extends StatefulWidget {
  final String entityId;

  const EntityControlFan({@required this.entityId});
  @override
  _EntityControlFanState createState() => _EntityControlFanState();
}

class _EntityControlFanState extends State<EntityControlFan> {
  double buttonValue = 150;
  double buttonHeight = 255.0;
  double buttonWidth = 90.0;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double buttonWidthInner = 82.0;
  double buttonHeightInner = 82.0;
  double onPos = 255.0 - 82.0 - 4.0;
  double offPos = 4.0;
  double diffY = 0;
  double snap = 10;
  int division = 4;
  int currentStep = 0;
  int changingStep = 0;
  double stepLength;

  @override
  void initState() {
    super.initState();
    Entity entity = gd.entities[widget.entityId];
    division = entity.speedList.length - 1;
    stepLength = (buttonHeight - buttonHeightInner - 8) / division;
    print(
        "entityId ${widget.entityId} division $division steps stepLength $stepLength");

    if (entity.isStateOn &&
        entity.speed != null &&
        entity.speedList != null &&
        entity.speedList.indexOf(entity.speed) >= 0) {
      currentStep = entity.speedList.indexOf(entity.speed);
      log.d(
          "entity.speed ${entity.speed} speedList ${entity.speedList} currentStep  $currentStep");
      changingStep = currentStep;
      diffY = currentStep * stepLength;
    }
    if (entity.isStateOn &&
        entity.speedLevel != null &&
        entity.speedLevel.indexOf(entity.speedLevel) >= 0) {
      currentStep = entity.speedList.indexOf(entity.speedLevel);
      log.d(
          "entity.speedLevel ${entity.speedLevel} speedList ${entity.speedList} currentStep  $currentStep");
      changingStep = currentStep;
      diffY = currentStep * stepLength;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state} | " +
          "${generalData.entities[widget.entityId].isStateOn} | " +
          "${generalData.entities[widget.entityId].speedList} | " +
          "${generalData.entities[widget.entityId].speed} | " +
          "${generalData.entities[widget.entityId].speedLevel} | " +
          "${generalData.entities[widget.entityId].angle} | " +
          "${generalData.entities[widget.entityId].oscillating} | ",
      builder: (context, data, child) {
        return new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) =>
              _onVerticalDragStart(context, details),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onVerticalDragUpdate(context, details),
          onVerticalDragEnd: (DragEndDetails details) =>
              _onVerticalDragEnd(context, details),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      color: currentStep > 0 ||
                              gd.entities[widget.entityId].isStateOn
                          ? ThemeInfo.colorIconActive
                          : ThemeInfo.colorIconInActive,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          width: 4, color: ThemeInfo.colorBottomSheetReverse),
                    ),
                  ),
                  Positioned(
                    bottom: 4 + diffY,
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        Container(
                          width: buttonWidthInner,
                          height: buttonHeightInner,
                          padding: const EdgeInsets.all(2.0),
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: currentStep > 0 ||
                                    gd.entities[widget.entityId].isStateOn
                                ? Colors.white.withOpacity(1)
                                : Colors.white.withOpacity(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius:
                                    1.0, // has the effect of softening the shadow
                                spreadRadius:
                                    0.5, // has the effect of extending the shadow
                                offset: Offset(
                                  0.0, // horizontal, move right 10
                                  1.0, // vertical, move down 10
                                ),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                  MaterialDesignIcons.getIconDataFromIconName(gd
                                      .entities[widget.entityId]
                                      .getDefaultIcon),
                                  size: 50,
                                  color: currentStep > 0 ||
                                          gd.entities[widget.entityId].isStateOn
                                      ? ThemeInfo.colorIconActive
                                      : ThemeInfo.colorIconInActive),
                              SizedBox(height: 4),
                              Text(
                                gd.textToDisplay(
                                    "${gd.entities[widget.entityId].getStateDisplay}"),
                                style: ThemeInfo.textStatusButtonActive,
                                maxLines: 1,
                                textScaleFactor:
                                    gd.textScaleFactor * 3 / gd.itemsPerRow,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Oscillating(entityId: widget.entityId),
            ],
          ),
        );
      },
    );
  }

  _onVerticalDragStart(BuildContext context, DragStartDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(BuildContext context, DragEndDetails details) {
    for (int i = division; i >= 0; i--) {
      if (diffY >= i * stepLength - stepLength / 2) {
        diffY = i * stepLength;
        currentStep = i;
        break;
      }
    }
    log.d("_onVerticalDragEnd currentStep $currentStep diffY $diffY");

    var outMsg;

    if (currentStep == 0) {
      outMsg = {
        "id": gd.socketId,
        "type": "call_service",
        "domain": "fan",
        "service": "turn_off",
        "service_data": {
          "entity_id": widget.entityId,
        }
      };
      gd.setState(gd.entities[widget.entityId], 'off', json.encode(outMsg));
    } else {
      outMsg = {
        "id": gd.socketId,
        "type": "call_service",
        "domain": "fan",
        "service": "set_speed",
        "service_data": {
          "entity_id": widget.entityId,
          "speed": gd.entities[widget.entityId].speedList[currentStep],
        }
      };
      gd.setFanSpeed(
          gd.entities[widget.entityId],
          gd.entities[widget.entityId].speedList[currentStep],
          json.encode(outMsg));
    }
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy - currentStep * stepLength;
      diffY = startPosY - currentPosY;
      diffY = diffY.clamp(0.0, onPos - 4);
      for (int i = division; i >= 0; i--) {
        if (diffY >= i * stepLength - stepLength / 2) {
          changingStep = i;
          break;
        }
      }
    });
  }
}

class Oscillating extends StatelessWidget {
  final String entityId;
  const Oscillating({@required this.entityId});
  @override
  Widget build(BuildContext context) {
    Entity entity = gd.entities[entityId];

    if (entity.oscillating == null) {
      return Container();
    }
    bool oscillating = entity.oscillating;
//    print("entity.oscillating ${oscillating}");

    return Column(
      children: <Widget>[
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            var outMsg = {
              "id": gd.socketId,
              "type": "call_service",
              "domain": "fan",
              "service": "oscillate",
              "service_data": {
                "entity_id": entity.entityId,
                "oscillating": !oscillating,
              }
            };

            gd.setFanOscillating(entity, !oscillating, json.encode(outMsg));

            Flushbar(
              title: !entity.oscillating
                  ? "Disable ${gd.textToDisplay(gd.entities[entityId].getOverrideName)} Oscilation"
                  : "Enable ${gd.textToDisplay(gd.entities[entityId].getOverrideName)} Oscilation",
              message: "Prevent accidentally open the secure doors...",
              duration: Duration(seconds: 3),
            )..show(context);
          },
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      width: 4, color: ThemeInfo.colorBottomSheetReverse),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 1.0, // has the effect of softening the shadow
                      spreadRadius:
                          0.5, // has the effect of extending the shadow
                      offset: Offset(
                        0.0, // horizontal, move right 10
                        1.0, // vertical, move down 10
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      width: 4, color: ThemeInfo.colorBottomSheetReverse),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 1.0, // has the effect of softening the shadow
                      spreadRadius:
                          0.5, // has the effect of extending the shadow
                      offset: Offset(
                        0.0, // horizontal, move right 10
                        1.0, // vertical, move down 10
                      ),
                    ),
                  ],
                ),
                child: Icon(
                  MaterialDesignIcons.getIconDataFromIconName(
                      "mdi:swap-horizontal"),
                  color: oscillating
                      ? ThemeInfo.colorIconActive
                      : ThemeInfo.colorIconInActive,
                  size: 70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
