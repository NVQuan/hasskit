import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EntityControlCamera extends StatefulWidget {
  final String entityId;

  const EntityControlCamera({@required this.entityId});

  @override
  _EntityControlCameraState createState() => _EntityControlCameraState();
}

class _EntityControlCameraState extends State<EntityControlCamera> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  bool showSpin = true;
  String url = "";
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays([]);
//    delayedHide();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          generalData.cameraStreamUrl + showSpin.toString() + url,
      builder: (context, data, child) {
        return RotatedBox(
          quarterTurns:
              Theme.of(context).platform == TargetPlatform.android ? 1 : 0,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              gd.cameraStreamUrl != ""
                  ? WebView(
                      initialUrl: gd.cameraStreamUrl,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      onPageFinished: (String urlVal) {
                        showSpin = false;
                        url = urlVal;
                        log.d('Page finished loading: $url');
//                        delayedHide();
                      },
                    )
                  : Container(),
              if (showSpin &&
                  Theme.of(context).platform == TargetPlatform.android)
                Container(
                  decoration: BoxDecoration(
                    color: ThemeInfo.colorBottomSheet,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SpinKitThreeBounce(
                        size: 40,
                        color: Theme.of(context)
                            .textTheme
                            .body1
                            .color
                            .withOpacity(0.5),
                      ),
                      SizedBox(height: 8),
                      Text(
                          "Loading ${gd.entities[widget.entityId].getOverrideName}"),
                    ],
                  ),
                )
              else
                Container(),

//               showSpin
//                  ? Image(
//                image: gd.getCameraThumbnail(widget.entityId),
//                fit: BoxFit.contain,
//              )
//                  : Container(),
//              showSpin
//                  ? SpinKitThreeBounce(
//                      size: 40,
//                      color: Colors.white54,
//                    )
//                  : Container(),

              Theme.of(context).platform == TargetPlatform.iOS
                  ? Positioned(
                      bottom: 40,
                      right: 40,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.cancel,
                          color: Theme.of(context)
                              .textTheme
                              .body1
                              .color
                              .withOpacity(0.5),
                          size: 40,
                        ),
                      ),
                    )
                  : Positioned(
                      top: 40,
                      right: 40,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.cancel,
                          color: ThemeInfo.colorBottomSheetReverse
                              .withOpacity(0.5),
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

  void delayedHide() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    showSpin = false;
    setState(() {});
  }
}
