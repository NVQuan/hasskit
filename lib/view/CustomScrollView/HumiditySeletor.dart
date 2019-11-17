import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';

class HumiditySelector extends StatefulWidget {
  final int roomIndex;
  const HumiditySelector({@required this.roomIndex});

  @override
  _HumiditySelectorState createState() => _HumiditySelectorState();
}

class _HumiditySelectorState extends State<HumiditySelector> {
  bool showPicker = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    List<Entity> entities = gd.entities.values
        .where((e) =>
            !e.entityId.contains("binary_sensor.") &&
            e.entityId.contains("sensor."))
        .toList();
    entities.sort((a, b) => gd
        .textToDisplay(a.getOverrideName)
        .compareTo(gd.textToDisplay(b.getOverrideName)));

    //LOL I DARE MYSELF TO UNDERSTAND THIS IN A MONTH
    selectedIndex = entities
            .indexOf(gd.entities[gd.roomList[widget.roomIndex].humidEntityId]) +
        1;

    FixedExtentScrollController tempSensorScrollController =
        FixedExtentScrollController(initialItem: selectedIndex);

    List<Widget> pickerWidget = [
      Row(
        children: <Widget>[
          SizedBox(width: 32),
          Expanded(
            child: Text(
              "Empty",
              style: Theme.of(context).textTheme.subhead,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textScaleFactor: gd.textScaleFactor,
            ),
          ),
          Text(
            "",
            style: Theme.of(context).textTheme.subhead,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textScaleFactor: gd.textScaleFactor,
          ),
          SizedBox(width: 16),
        ],
      )
    ];
    for (Entity entity in entities) {
      var widget = Row(
        children: <Widget>[
//            Icon(
//              MaterialDesignIcons.getIconDataFromIconName(sensor.icon),
//              color: ThemeInfo.colorBottomSheetReverse,
//            ),
          SizedBox(width: 32),
          Expanded(
            child: Text(
              gd.textToDisplay(entity.getOverrideName),
              style: Theme.of(context).textTheme.subhead,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textScaleFactor: gd.textScaleFactor,
            ),
          ),
          Text(
            gd.textToDisplay(entity.state),
            style: Theme.of(context).textTheme.subhead,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textScaleFactor: gd.textScaleFactor,
          ),
          SizedBox(width: 16),
        ],
      );
      pickerWidget.add(widget);
    }

    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            margin: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                Container(
                  padding: showPicker
                      ? EdgeInsets.only(
                          bottom: 8,
                        )
                      : EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          showPicker = !showPicker;
                          setState(() {});
                          gd.delayCancelEditModeTimer(300);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                MaterialDesignIcons.getIconDataFromIconName(
                                    "mdi:water-percent"),
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                "Humidity Sensor",
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: gd.textScaleFactor,
                                maxLines: 1,
                              )),
                              Text(
                                gd.roomList[widget.roomIndex].humidEntityId
                                            .length >
                                        0
                                    ? gd.textToDisplay(
                                        entities[selectedIndex - 1]
                                            .getOverrideName)
                                    : "Select Sensor",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                textScaleFactor: gd.textScaleFactor,
                                style: ThemeInfo.pickerActivateStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                      showPicker
                          ? Container(
                              height: 150,
                              child: CupertinoPicker(
                                squeeze: 0.9,
                                diameterRatio: 1000,
                                scrollController: tempSensorScrollController,
                                magnification: 1.05,
                                backgroundColor:
                                    ThemeInfo.colorBottomSheet.withOpacity(0.8),
                                children: pickerWidget,
                                itemExtent: 30, //height of each item
                                looping: false,
                                onSelectedItemChanged: (int index) {
                                  if (index == 0) {
                                    gd.roomList[widget.roomIndex]
                                        .humidEntityId = "";
                                  } else {
                                    gd.roomList[widget.roomIndex]
                                            .humidEntityId =
                                        entities[index - 1].entityId;
                                    log.d(
                                        "humidEntityId ${gd.roomList[widget.roomIndex].humidEntityId}");
                                  }
                                  gd.roomListSave();
                                  setState(() {});
                                },
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
