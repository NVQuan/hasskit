import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/view/CustomScrollView/ViewNormal.dart';
import 'package:hasskit/view/CustomScrollView/ViewSort.dart';
import 'package:hasskit/view/DefaultPage.dart';
import 'package:provider/provider.dart';

import 'CustomScrollView/ViewEdit.dart';

class PageViewBuilder extends StatelessWidget {
  final PageController controller =
      PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
  @override
  Widget build(BuildContext context) {
//    log.w("Widget build RoomsPage");
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.connectionStatus} |" +
          "${generalData.lastLifecycleState} |" +
          "${generalData.roomList.length} |",
      builder: (context, data, child) {
        gd.pageController = controller;
        return gd.roomList != null && gd.roomList.length > 0
            ? PageView.builder(
                controller: controller,
                onPageChanged: (int) {
                  gd.viewMode = ViewMode.normal;
                  gd.lastSelectedRoom = int;
                },
                itemBuilder: (context, position) {
                  try {
                    return SinglePage(roomIndex: position + 1);
                  } catch (e) {
                    return DefaultPage(error: e.toString());
                  }
                },
                itemCount: gd.roomListLength)
            : PageView.builder(
                controller: controller,
                onPageChanged: (val) {
                  gd.lastSelectedRoom = val;
                },
                itemBuilder: (context, position) {
                  return SinglePage(roomIndex: 0);
                },
                itemCount: 1);
      },
    );
  }
}

class SinglePage extends StatelessWidget {
  final int roomIndex;

  const SinglePage({@required this.roomIndex});

  @override
  Widget build(BuildContext context) {
//    log.w("Widget build HomePage");

    if (gd.roomList == null || gd.roomList.length < 1) {
      return DefaultPage(error: "..HassKit..");
    }

    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.viewMode} |" +
          "${generalData.connectionStatus} |" +
          "${generalData.mediaQueryHeight} |" +
          "${generalData.roomList.length} |" +
          "${generalData.entities.length} |" +
          "${generalData.roomList[roomIndex].name} |" +
          "${generalData.roomList[roomIndex].tempEntityId} |" +
          "${generalData.roomList[roomIndex].imageIndex} |" +
          "${generalData.toggleStatusMap.values.toList()} |" +
          "${generalData.roomList[roomIndex].favorites.toList()} |" +
          "${generalData.roomList[roomIndex].entities.toList()} |" +
          "${generalData.roomList[roomIndex].row3.toList()} |" +
          "${generalData.roomList[roomIndex].row4.toList()} |",
      builder: (context, data, child) {
        Widget widget;
        if (gd.viewMode == ViewMode.edit) {
          widget = ViewEdit(roomIndex: roomIndex);
        } else if (gd.viewMode == ViewMode.sort) {
          widget = ViewSort(roomIndex: roomIndex);
        } else {
          widget = ViewNormal(roomIndex: roomIndex);
        }

        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: gd.getRoomImage(roomIndex),
              fit: BoxFit.cover,
            ),
          ),
          child: widget,
        );
      },
    );
  }
}
