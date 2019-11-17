import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';
import 'package:hasskit/helper/WebSocket.dart';
import 'package:hasskit/model/LoginData.dart';

class ServerSelectPanel extends StatelessWidget {
  final LoginData loginData;
  const ServerSelectPanel(this.loginData);
  @override
  Widget build(BuildContext context) {
//    log.w("Widget build ServerSelectPanel");
    List<Widget> secondaryWidgets;
    Widget deleteWidget = new IconSlideAction(
        caption: 'Delete',
        color: Colors.transparent,
        icon: Icons.delete,
        onTap: () {
          log.w("ServerSelectPanel Delete");
          gd.loginDataListDelete(loginData);
          gd.autoConnect = false;
          gd.currentUrl = "";
          if (gd.loginDataCurrent.getUrl == loginData.getUrl) {
            gd.loginDataCurrent.url = "";
            webSocket.reset();
            gd.roomListClear();
          }
        });
    secondaryWidgets = [deleteWidget];
    if (gd.loginDataCurrent.getUrl == loginData.getUrl) {
      var disconnectWidget = IconSlideAction(
          caption: 'Disconnect',
          color: Colors.transparent,
          icon: MaterialDesignIcons.getIconDataFromIconName(
              "mdi:server-network-off"),
          onTap: () {
            log.w("ServerSelectPanel Disconnect");
            gd.autoConnect = false;
            gd.currentUrl = "";
            webSocket.reset();
            gd.roomListClear();
          });
      secondaryWidgets = [disconnectWidget, deleteWidget];
    } else {
      secondaryWidgets = [deleteWidget];
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: InkWell(
        onTap: () {
          log.d("log.d OnTap");
          print("print OnTap");
          debugPrint("debugPrint OnTap");
          if (gd.loginDataCurrent.getUrl == loginData.getUrl &&
              gd.connectionStatus == "Connected") {
            Flushbar(
//              title: "Require Slide to Open",
              message:
                  "Swipe Right to Refresh, Left to Disconnect/Delete Server",
              duration: Duration(seconds: 3),
            )..show(context);
          } else {
            Flushbar(
//              title: "Require Slide to Open",
              message: "Swipe Right to Connect, Left to Delete Server",
              duration: Duration(seconds: 3),
            )..show(context);
          }
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Card(
          margin: EdgeInsets.all(4),
          color: Theme.of(context).canvasColor.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: <Widget>[
                gd.loginDataCurrent.getUrl == loginData.getUrl &&
                        gd.connectionStatus == "Connected"
                    ? Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:server-network"),
                        color: Theme.of(context).toggleableActiveColor,
                      )
                    : Icon(
                        MaterialDesignIcons.getIconDataFromIconName(
                            "mdi:server-network-off"),
                        color: Theme.of(context)
                            .toggleableActiveColor
                            .withOpacity(0.5),
                      ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(loginData.getUrl,
                          style: Theme.of(context).textTheme.subhead,
                          maxLines: 2,
                          textScaleFactor: gd.textScaleFactor,
                          overflow: TextOverflow.ellipsis),
                      Text(
                          gd.loginDataCurrent.getUrl == loginData.getUrl
                              ? "Status: ${gd.connectionStatus}"
                              : "Last Access: ${loginData.timeSinceLastAccess}",
                          style: Theme.of(context).textTheme.body1,
                          maxLines: 5,
                          textScaleFactor: gd.textScaleFactor,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        (gd.loginDataCurrent.getUrl == loginData.getUrl &&
                gd.connectionStatus == "Connected")
            ? IconSlideAction(
                caption: 'Refresh',
                color: Colors.transparent,
                icon:
                    MaterialDesignIcons.getIconDataFromIconName("mdi:refresh"),
                onTap: () {
                  gd.autoConnect = true;
                  webSocket.initCommunication();
                })
            : IconSlideAction(
                caption: 'Connect',
                color: Colors.transparent,
                icon: MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:server-network"),
                onTap: () {
                  gd.loginDataCurrent = loginData;
                  gd.autoConnect = true;
                  webSocket.initCommunication();
                }),
      ],
      secondaryActions: secondaryWidgets,
    );
  }
}
