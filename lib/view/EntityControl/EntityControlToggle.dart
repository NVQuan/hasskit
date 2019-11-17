import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';

class EntityControlToggle extends StatefulWidget {
  final String entityId;

  const EntityControlToggle({@required this.entityId});
  @override
  _EntityControlToggleState createState() => _EntityControlToggleState();
}

class _EntityControlToggleState extends State<EntityControlToggle> {
  double buttonValue = 150;
  double buttonHeight = 255.0;
  double buttonWidth = 90.0;
  double currentPosX;
  double currentPosY;
  double startPosX;
  double startPosY;
  double buttonWidthInner = 82.0;
  double buttonHeightInner = 123.5;
  double onPos = 255.0 - 123.5 - 4.0;
  double offPos = 4.0;
  double diffY = 0;
  double snap = 10;

  @override
  Widget build(BuildContext context) {
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
                  color: gd.entities[widget.entityId].isStateOn
                      ? ThemeInfo.colorIconActive
                      : ThemeInfo.colorIconInActive,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      width: 4, color: ThemeInfo.colorBottomSheetReverse),
                ),
              ),
              Positioned(
                bottom: gd.entities[widget.entityId].isStateOn
                    ? onPos + diffY
                    : offPos + diffY,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: <Widget>[
                    Container(
                      width: buttonWidthInner,
                      height: buttonHeightInner,
                      padding: const EdgeInsets.all(2.0),
                      decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: gd.entities[widget.entityId].isStateOn
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
                              MaterialDesignIcons.getIconDataFromIconName(
                                  gd.entities[widget.entityId].getDefaultIcon),
                              size: 70,
                              color: gd.entities[widget.entityId].isStateOn
                                  ? ThemeInfo.colorIconActive
                                  : ThemeInfo.colorIconInActive),
                          SizedBox(height: 8),
                          Text(
                            gd.textToDisplay(
                                gd.entities[widget.entityId].state),
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
          RequireSlideToOpen(entityId: widget.entityId),
        ],
      ),
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
    setState(
      () {
        log.d("_onVerticalDragEnd");
        diffY = 0;
      },
    );
  }

  _onVerticalDragUpdate(BuildContext context, DragUpdateDetails details) {
    final RenderBox box = context.findRenderObject();
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    setState(() {
      currentPosX = localOffset.dx;
      currentPosY = localOffset.dy;
      diffY = startPosY - currentPosY;
      if (gd.entities[widget.entityId].isStateOn && diffY > 0) diffY = 0;
      if (gd.entities[widget.entityId].isStateOn &&
          diffY < buttonHeightInner - buttonHeight + 8 + snap) {
        diffY = buttonHeightInner - buttonHeight + 8;
        gd.toggleStatus(gd.entities[widget.entityId]);
      }
      if (!gd.entities[widget.entityId].isStateOn && diffY < 0) diffY = 0;
      if (!gd.entities[widget.entityId].isStateOn &&
          diffY > buttonHeight - buttonHeightInner - 8 - snap) {
        diffY = buttonHeight - buttonHeightInner - 8;
        gd.toggleStatus(gd.entities[widget.entityId]);
      }
//      print("yDiff $diffY");
    });
  }
}

class RequireSlideToOpen extends StatelessWidget {
  final String entityId;

  const RequireSlideToOpen({@required this.entityId});
  @override
  Widget build(BuildContext context) {
    if (!entityId.contains("cover.")) {
      return Container();
    }

    bool required = false;

    if (gd.entitiesOverride[entityId] != null &&
        gd.entitiesOverride[entityId].openRequireAttention != null &&
        gd.entitiesOverride[entityId].openRequireAttention == true) {
      required = true;
    }

    return Column(
      children: <Widget>[
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            gd.requireSlideToOpenAddRemove(entityId);
            Flushbar(
              title: required
                  ? "Disable Require Slide to Open ${gd.textToDisplay(gd.entities[entityId].getOverrideName)}"
                  : "Enable Require Slide to Open ${gd.textToDisplay(gd.entities[entityId].getOverrideName)}",
              message: required
                  ? "Thank for using HassKit..."
                  : "Prevent accidentally open the secure doors...",
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
                  required ? Icons.phonelink_lock : Icons.phonelink_erase,
                  color: required
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
