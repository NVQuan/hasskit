import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/Entity.dart';

class TemperatureSelector extends StatefulWidget {
  final int roomIndex;
  const TemperatureSelector({@required this.roomIndex});

  @override
  _TemperatureSelectorState createState() => _TemperatureSelectorState();
}

class _TemperatureSelectorState extends State<TemperatureSelector> {
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

    FixedExtentScrollController tempSensorScrollController =
        FixedExtentScrollController(initialItem: selectedIndex);

    List<String> pickerEntityId = [];
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
      var tempVal = double.tryParse(entity.state);
      if (tempVal == null) continue;
      pickerEntityId.add(entity.entityId);
      var widget = Row(
        children: <Widget>[
          SizedBox(width: 16),
          Icon(
            MaterialDesignIcons.getIconDataFromIconName(entity.getDefaultIcon),
            color: ThemeInfo.colorBottomSheetReverse,
          ),
          SizedBox(width: 4),
//          SizedBox(width: 32),
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

    //LOL I DARE MYSELF TO UNDERSTAND THIS IN A MONTH
    selectedIndex =
        pickerEntityId.indexOf(gd.roomList[widget.roomIndex].tempEntityId) + 1;

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
                                    "mdi:thermometer"),
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                "Temperature Sensor",
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: gd.textScaleFactor,
                                maxLines: 1,
                              )),
                              Text(
                                selectedIndex != 0 &&
                                        pickerEntityId[selectedIndex - 1]
                                                .length >
                                            0
                                    ? gd.textToDisplay(gd
                                        .entities[
                                            pickerEntityId[selectedIndex - 1]]
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
//                              decoration: BoxDecoration(
//                                image: DecorationImage(
//                                    image: AssetImage(
//                                        "assets/images/gradient-1.png"),
//                                    fit: BoxFit.fill),
//                              ),
                              height: 150,
                              child: CupertinoPicker(
                                squeeze: 0.9,
                                diameterRatio: 6,
                                scrollController: tempSensorScrollController,
                                magnification: 1.05,
                                backgroundColor:
                                    ThemeInfo.colorBottomSheet.withOpacity(0.8),
                                children: pickerWidget,
                                itemExtent: 30, //height of each item
                                looping: false,
                                onSelectedItemChanged: (int index) {
                                  if (index == 0) {
                                    gd.roomList[widget.roomIndex].tempEntityId =
                                        "";
                                  } else {
                                    gd.roomList[widget.roomIndex].tempEntityId =
                                        pickerEntityId[index - 1];
                                    log.w(
                                        "tempEntityId ${gd.roomList[widget.roomIndex].tempEntityId}");
                                  }
                                  gd.roomListSave();
                                  gd.notify();
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
