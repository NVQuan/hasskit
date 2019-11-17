import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class EntitySquare extends StatelessWidget {
  final String entityId;
  final Function onTapCallback;
  final Function onLongPressCallback;
  final Color borderColor;
  final String indicatorIcon;
  const EntitySquare(
      {@required this.entityId,
      @required this.onTapCallback,
      @required this.onLongPressCallback,
      @required this.borderColor,
      @required this.indicatorIcon});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.connectionStatus} " +
          "${generalData.entities[entityId].state} " +
          "${generalData.entities[entityId].getOverrideName} " +
          "${generalData.entities[entityId].getOverrideIcon} ",
      builder: (context, data, child) {
//    return Consumer<GeneralData>(
//      builder: (context, gd, child) {
        return Hero(
          tag: entityId,
          child: InkWell(
            onTap: onTapCallback,
            onLongPress: onLongPressCallback,
            child: Container(
              padding: EdgeInsets.all(8 * 3 / gd.itemsPerRow),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(16 * 3 / gd.itemsPerRow)),
                color: gd.entities[entityId].isStateOn
                    ? ThemeInfo.colorBackgroundActive
                    : ThemeInfo.colorEntityBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: <Widget>[
                        _EntityIcon(
                          entityId: entityId,
                        ),
                        Expanded(
                          child: FittedBox(
                            alignment: Alignment.centerRight,
                            child: (gd.showSpin ||
                                    gd.entities[entityId].state.contains("..."))
                                ? SpinKitThreeBounce(
                                    size: 100,
                                    color: ThemeInfo.colorIconActive,
                                  )
                                : gd.viewMode == ViewMode.sort
                                    ? Icon(
                                        MaterialDesignIcons
                                            .getIconDataFromIconName(
                                                "mdi:cursor-move"),
                                        size: 100,
                                        color: Colors.amber.withOpacity(0.8),
                                      )
                                    : Container(
                                        width: 1,
                                        height: 1,
                                      ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "${gd.entities[entityId].getOverrideName}",
                        style: gd.entities[entityId].isStateOn
                            ? ThemeInfo.textNameButtonActive
                            : ThemeInfo.textNameButtonInActive,
                        maxLines: 2,
                        textScaleFactor:
                            gd.textScaleFactor * 3 / gd.itemsPerRow,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      "${gd.textToDisplay(gd.entities[entityId].getStateDisplay)}",
                      style: gd.entities[entityId].isStateOn
                          ? ThemeInfo.textStatusButtonActive
                          : ThemeInfo.textStatusButtonInActive,
                      maxLines: 1,
                      textScaleFactor: gd.textScaleFactor * 3 / gd.itemsPerRow,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EntityIcon extends StatelessWidget {
  final String entityId;

  const _EntityIcon({@required this.entityId});
  @override
  Widget build(BuildContext context) {
//    log.d("Widget build _EntityIcon $entityId");

    var iconWidget;
    var entity = gd.entities[entityId];
    if (entity.entityId.contains("climate.")) {
      iconWidget = AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                Icons.brightness_1,
                color: gd.climateModeToColor(entity.state),
              ),
              Column(
                children: <Widget>[
                  Text(
                    "${entity.temperature.toInt()}",
                    style: ThemeInfo.textNameButtonActive.copyWith(
                      color: ThemeInfo.colorBottomSheet,
                    ),
                    textScaleFactor:
                        gd.textScaleFactor * 0.8 * 3 / gd.itemsPerRow,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else {
      iconWidget = AspectRatio(
        aspectRatio: 1,
        child: FittedBox(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(
                entity.mdiIcon,
                color: entity.isStateOn
                    ? ThemeInfo.colorIconActive
                    : ThemeInfo.colorIconInActive,
              ),
            ],
          ),
        ),
      );
    }
    return iconWidget;
  }
}
