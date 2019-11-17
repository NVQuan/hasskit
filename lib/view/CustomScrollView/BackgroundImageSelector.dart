import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/ThemeInfo.dart';

class BackgroundImageSelector extends StatefulWidget {
  final int roomIndex;
  const BackgroundImageSelector({@required this.roomIndex});

  @override
  _BackgroundImageSelectorState createState() =>
      _BackgroundImageSelectorState();
}

class _BackgroundImageSelectorState extends State<BackgroundImageSelector> {
  bool showPicker = false;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    //LOL I DARE MYSELF TO UNDERSTAND THIS IN A MONTH
    selectedIndex = gd.roomList[widget.roomIndex].imageIndex;

    FixedExtentScrollController tempSensorScrollController =
        FixedExtentScrollController(initialItem: selectedIndex);

    List<Widget> pickerWidget = [];
    for (String image in gd.backgroundImage) {
      String imageDisplay = image.replaceAll("assets/background_images/", "");
      imageDisplay = imageDisplay.replaceAll(".jpg", "");
      imageDisplay = gd.textToDisplay(imageDisplay);
      var widget = Row(
        children: <Widget>[
//            Icon(
//              MaterialDesignIcons.getIconDataFromIconName(sensor.icon),
//              color: ThemeInfo.colorBottomSheetReverse,
//            ),
          SizedBox(width: 32),
          Expanded(
            child: Text(
              imageDisplay,
              style: Theme.of(context).textTheme.subhead,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              textScaleFactor: gd.textScaleFactor,
            ),
          ),

          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: ThemeInfo.colorBottomSheetReverse,
                width: 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image(
                width: 48,
                height: 48,
                image: AssetImage(image),
              ),
            ),
          ),

          SizedBox(width: 8),
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
                              Icon(MaterialDesignIcons.getIconDataFromIconName(
                                  "mdi:image")),
                              SizedBox(width: 8),
                              Expanded(
                                  child: Text(
                                "${gd.roomList[widget.roomIndex].name} Background Image",
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: gd.textScaleFactor,
                                maxLines: 1,
                              )),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
//                                  color: ThemeInfo.colorBottomSheetReverse,
                                    color: ThemeInfo.pickerActivateStyle.color,

                                    width: 1.0,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image(
                                    width: 48,
                                    height: 48,
                                    image: AssetImage(gd.backgroundImage[gd
                                        .roomList[widget.roomIndex]
                                        .imageIndex]),
                                  ),
                                ),
                              ),
                              SizedBox(width: 2),
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
//                                color: Colors.black,
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
                                itemExtent: 48,
                                //height of each item
                                looping: false,
                                onSelectedItemChanged: (int index) {
                                  gd.setRoomBackgroundImage(
                                      gd.roomList[widget.roomIndex], index);

                                  log.d(
                                      "imageIndex ${gd.roomList[widget.roomIndex].imageIndex}");
                                  gd.roomListSave();
                                  setState(() {});
                                },
                              ),
                            )
                          : Container(
                              height: 0,
                            ),
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
