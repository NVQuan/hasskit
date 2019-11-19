import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/model/Entity.dart';
import 'package:provider/provider.dart';
import 'package:tinycolor/tinycolor.dart';

List<String> colorTemps = [
  "64B5F6", //Blue
  "90CAF9", //Blue
  "BBDEFB", //Blue
  "F5F5F5", //Gray
  "FFF9C4", //Yellow
  "FFF59D", //Yellow
  "FFF176", //Yellow
];

class EntityControlLightDimmer extends StatefulWidget {
  final String entityId;
  const EntityControlLightDimmer({@required this.entityId});

  @override
  _EntityControlLightDimmerState createState() =>
      _EntityControlLightDimmerState();
}

class _EntityControlLightDimmerState extends State<EntityControlLightDimmer> {
  @override
  Widget build(BuildContext context) {
//    log.d(
//        "${widget.entityId} entities[widget.entityId].supportedFeaturesLights ${gd.entities[widget.entityId].getSupportedFeaturesLights} ${gd.entities[widget.entityId].supportedFeatures}");
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ButtonSlider(
            entityId: widget.entityId,
          ),
          SizedBox(height: 10),
          gd.entities[widget.entityId].getSupportedFeaturesLights
                  .contains("SUPPORT_RGB_COLOR")
              ? RgbColorSelector(
                  entityId: widget.entityId,
                )
              : gd.entities[widget.entityId].getSupportedFeaturesLights
                      .contains("SUPPORT_COLOR_TEMP")
                  ? TempColorSelector(
                      entityId: widget.entityId,
                    )
                  : Container(),
        ],
      ),
    );
  }
}

class ButtonSlider extends StatefulWidget {
  final String entityId;

  const ButtonSlider({@required this.entityId});

  @override
  State<StatefulWidget> createState() {
    return new ButtonSliderState();
  }
}

class ButtonSliderState extends State<ButtonSlider> {
  double buttonHeight = 255.0;
  double buttonWidth = 90.0;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  Offset buttonPos;
  Size buttonSize;
  double buttonValue;
  double buttonValueMin = 50.0;
  double buttonValueOnTapDown = 0;
  String raisedButtonLabel = "";
  //creating Key for red panel
  GlobalKey buttonKey = GlobalKey();
  DateTime draggingTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[widget.entityId].state} " +
          "${generalData.entities[widget.entityId].brightness} " +
          "${generalData.entities[widget.entityId].colorTemp} " +
          "${generalData.entities[widget.entityId].rgbColor} ",
      builder: (context, data, child) {
        if (draggingTime.millisecondsSinceEpoch <
            DateTime.now().millisecondsSinceEpoch) {
          if (!gd.entities[widget.entityId].isStateOn) {
            buttonValue = buttonValueMin;
          } else {
            buttonValue = buttonValueMin +
                gd.entities[widget.entityId].brightness.toDouble();
          }
        }
        var colorForeground = ThemeInfo.colorBottomSheetReverse;
        TinyColor sliderColor;
        if (!gd.entities[widget.entityId].isStateOn) {
          sliderColor = TinyColor.fromRGB(r: 128, g: 128, b: 128);
        } else if (gd.entities[widget.entityId].getSupportedFeaturesLights
            .contains("SUPPORT_RGB_COLOR")) {
          var entityRGB = gd.entities[widget.entityId].rgbColor;
          if (entityRGB == null ||
              entityRGB.length < 3 ||
              entityRGB[0] > 250 && entityRGB[1] > 250 && entityRGB[2] > 250)
            entityRGB = [224, 224, 224];
          sliderColor = TinyColor.fromRGB(
              r: entityRGB[0], g: entityRGB[1], b: entityRGB[2]);
        } else if (gd.entities[widget.entityId].getSupportedFeaturesLights
                .contains("SUPPORT_COLOR_TEMP") &&
            gd.entities[widget.entityId].colorTemp != null &&
            gd.entities[widget.entityId].maxMireds != null &&
            gd.entities[widget.entityId].minMireds != null) {
          var colorTemp = gd.entities[widget.entityId].colorTemp;
          var minMireds = gd.entities[widget.entityId].minMireds;
          var maxMireds = gd.entities[widget.entityId].maxMireds;
          var miredsDivided = (maxMireds - minMireds) / 7;
          var miredsDividedHalf = miredsDivided / 2;
//          log.d(
//              "colorTemp $colorTemp minMireds $minMireds maxMireds $maxMireds miredsDivided $miredsDivided");
          if (colorTemp <= minMireds + miredsDivided * 1 - miredsDividedHalf)
            sliderColor = TinyColor.fromString(colorTemps[0]);
          else if (colorTemp <=
              minMireds + miredsDivided * 2 - miredsDividedHalf)
            sliderColor = TinyColor.fromString(colorTemps[1]);
          else if (colorTemp <=
              minMireds + miredsDivided * 3 - miredsDividedHalf)
            sliderColor = TinyColor.fromString(colorTemps[2]);
          else if (colorTemp <=
              minMireds + miredsDivided * 4 - miredsDividedHalf)
            sliderColor = TinyColor.fromString(colorTemps[3]);
          else if (colorTemp <=
              minMireds + miredsDivided * 5 - miredsDividedHalf)
            sliderColor = TinyColor.fromString(colorTemps[4]);
          else if (colorTemp <=
              minMireds + miredsDivided * 6 - miredsDividedHalf)
            sliderColor = TinyColor.fromString(colorTemps[5]);
          else
            sliderColor = TinyColor.fromString(colorTemps[6]);
        } else {
          sliderColor = TinyColor.fromRGB(r: 192, g: 192, b: 192);
        }

        return new GestureDetector(
          onVerticalDragStart: (DragStartDetails details) =>
              _onVerticalDragStart(context, details),
          onVerticalDragUpdate: (DragUpdateDetails details) =>
              _onVerticalDragUpdate(context, details),
          onVerticalDragEnd: (DragEndDetails details) => _onVerticalDragEnd(
              context, details, gd.entities[widget.entityId]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    key: buttonKey,
                    width: buttonWidth,
                    height: buttonHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: 4, color: colorForeground),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: buttonWidth - 8,
                        height: buttonHeight - 8,
                        color: ThemeInfo.colorIconInActive,
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: buttonWidth,
                          height: buttonValue,
                          alignment: Alignment.topCenter,
                          decoration: BoxDecoration(
                            color: sliderColor.color.withOpacity(1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius:
                                    1.0, // has the effect of softening the shadow
                                spreadRadius:
                                    1.0, // has the effect of extending the shadow
                                offset: Offset(
                                  0.0, // horizontal, move right 10
                                  0.0, // vertical, move down 10
                                ),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(
                              MaterialDesignIcons.getIconDataFromIconName(
                                  gd.entities[widget.entityId].getDefaultIcon),
                              size: 45,
                              color: ThemeInfo.colorBottomSheetReverse,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
//              Text("${gd.entities[widget.entityId].rgbColor}"),
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
      draggingTime = DateTime.now().add(Duration(seconds: 1));
      startPosX = localOffset.dx;
      startPosY = localOffset.dy;
      buttonValueOnTapDown = buttonValue;
      log.d(
          "_onVerticalDragStart startPosX ${startPosX.toStringAsFixed(0)} startPosY ${startPosY.toStringAsFixed(0)}");
    });
  }

  _onVerticalDragEnd(
      BuildContext context, DragEndDetails details, Entity entity) {
    setState(
      () {
        draggingTime = DateTime.now().add(Duration(seconds: 1));
        log.d("_onVerticalDragEnd");
        var outMsg;
        if (buttonValue.toInt() <= buttonValueMin + buttonHeight / 50) {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": entity.entityId.split('.').first,
            "service": "turn_off",
            "service_data": {
              "entity_id": entity.entityId,
            },
          };
        } else {
          outMsg = {
            "id": gd.socketId,
            "type": "call_service",
            "domain": entity.entityId.split('.').first,
            "service": "turn_on",
            "service_data": {
              "entity_id": entity.entityId,
//              "brightness": buttonValue.toInt()
              "brightness": gd
                  .mapNumber(buttonValue, buttonValueMin, buttonHeight, 0, 255)
                  .toInt()
            },
          };
        }
        var outMsgEncoded = json.encode(outMsg);
        webSocket.send(outMsgEncoded);
        HapticFeedback.mediumImpact();
      },
    );
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      draggingTime = DateTime.now().add(Duration(seconds: 1));
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
//      log.d(
//          "_onVerticalDragUpdate currentPosX ${currentPosX.toStringAsFixed(0)} currentPosY ${currentPosY.toStringAsFixed(0)}");
      buttonValue = buttonValueOnTapDown + (startPosY - currentPosY);
      buttonValue = buttonValue.clamp(buttonValueMin, buttonHeight);
    });
  }
}

class RgbColorSelector extends StatefulWidget {
  final String entityId;

  const RgbColorSelector({@required this.entityId});
  @override
  _RgbColorSelectorState createState() => _RgbColorSelectorState();
}

class _RgbColorSelectorState extends State<RgbColorSelector> {
  List<String> colors = [
    "E0E0E0", //Gray
    "E57373", //Red
    "F06292", //Pink
    "BA68C8", //Purple
    "9575CD", //Deep purple
    "7986CB", //Indigo
    "64B5F6", //Blue
    "4FC3F7", //Light Blue
    "4DD0E1", //Cyan
//    "4DB6AC", //Teal
    "81C784", //Green
    "AED581", //Light Green
//    "DCE775", //Lime
    "FFF176", //Yellow
    "FFD54F", //Amber
    "FFB74D", //Orange
//    "FF8A65", //Deep Orange
//    "A1887F", //Brown
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        var selectedColor =
                            TinyColor.fromString(colors[index]).color;
                        var outMsg = {
                          "id": gd.socketId,
                          "type": "call_service",
                          "domain": gd.entities[widget.entityId].entityId
                              .split('.')
                              .first,
                          "service": "turn_on",
                          "service_data": {
                            "entity_id": widget.entityId,
                            "brightness": 255,
                            "rgb_color": [
                              selectedColor.red,
                              selectedColor.green,
                              selectedColor.blue
                            ]
                          },
                        };

                        var outMsgEncoded = json.encode(outMsg);
                        webSocket.send(outMsgEncoded);
                        HapticFeedback.mediumImpact();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeInfo.colorBottomSheetReverse,
//                            border: Border.all(width: 0, color: Colors.white),
                      ),
                      child: CircleAvatar(
                        backgroundColor:
                            TinyColor.fromString("${colors[index]}").color,
                      ),
                    ),
                  );
                },
                childCount: colors.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TempColorSelector extends StatefulWidget {
  final String entityId;

  const TempColorSelector({@required this.entityId});
  @override
  _TempColorSelectorState createState() => _TempColorSelectorState();
}

class _TempColorSelectorState extends State<TempColorSelector> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 115,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.all(8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                childAspectRatio: 1,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        var outMsg = {
                          "id": gd.socketId,
                          "type": "call_service",
                          "domain": gd.entities[widget.entityId].entityId
                              .split('.')
                              .first,
                          "service": "turn_on",
                          "service_data": {
                            "entity_id": widget.entityId,
                            "brightness": 255,
                            "color_temp": gd
                                .mapNumber(
                                    index.toDouble(),
                                    0,
                                    colorTemps.length.toDouble() - 1,
                                    gd.entities[widget.entityId].minMireds
                                        .toDouble(),
                                    gd.entities[widget.entityId].maxMireds
                                            .toDouble() -
                                        1)
                                .toInt()
                          },
                        };

                        var outMsgEncoded = json.encode(outMsg);
                        webSocket.send(outMsgEncoded);
                        HapticFeedback.mediumImpact();

                        log.d(
                            "minMireds ${gd.entities[widget.entityId].minMireds} "
                            "maxMireds ${gd.entities[widget.entityId].maxMireds} "
                            "index $index");
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ThemeInfo.colorBottomSheetReverse,
                      ),
                      child: CircleAvatar(
                        backgroundColor:
                            TinyColor.fromString("${colorTemps[index]}").color,
                      ),
                    ),
                  );
                },
                childCount: colorTemps.length,
              ),
            ),
          )
        ],
      ),
    );
  }
}
