import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import '../SliverAppBarDelegate.dart';

class MakeHeaderIcon extends StatelessWidget {
  final Color color;
  final Icon icon;
  final String headerText;
  final String subText;
  final BuildContext context;

  const MakeHeaderIcon(
      {this.color, this.icon, this.headerText, this.subText, this.context});

  @override
  Widget build(BuildContext context) {
//    log.w("Widget build MakeHeaderIcon");
//    return Selector<GeneralData, int>(
//      selector: (_, generalData) => gd.lastSelectedRoom,
//      builder: (_, lastSelectedRoom, __) {
    return SliverPersistentHeader(
      pinned: true,
      floating: false,
      delegate: SliverAppBarDelegate(
        minHeight: 24,
        maxHeight: 60,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: color,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 12),
                        ClipRRect(
                          borderRadius: new BorderRadius.circular(4.0),
                          child: icon,
                        ),
                        SizedBox(width: 8),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              headerText,
                              textScaleFactor: gd.textScaleFactor,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subText.length > 0
                                ? Text(
                                    subText,
                                    textScaleFactor: gd.textScaleFactor,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Container(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
//      },
//    );
  }
}
