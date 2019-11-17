import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:hasskit/model/CameraThumbnail.dart';
import 'package:provider/provider.dart';

class EntityRectangle extends StatelessWidget {
  final String entityId;
  final Color borderColor;
  final Function onTapCallback;
  final Function onLongPressCallback;

  const EntityRectangle({
    @required this.entityId,
    @required this.borderColor,
    @required this.onTapCallback,
    @required this.onLongPressCallback,
  });

  @override
  Widget build(BuildContext context) {
//    log.w("Widget build EntityRectangle $entityId");

//    return Selector<GeneralData, Map<String, Entity>>(
//      selector: (_, generalData) => generalData.entities,
//      builder: (_, entity, __) {
    return Selector<GeneralData, CameraThumbnail>(
      selector: (_, generalData) => generalData.cameraThumbnails[entityId],
      builder: (context, data, child) {
        return VisibilityDetector(
          key: Key(entityId),
          onVisibilityChanged: (VisibilityInfo info) {
            if (info.visibleFraction > 0.5 &&
                !gd.activeCameras.containsKey(entityId)) {
              gd.activeCameras[entityId] =
                  DateTime.now().subtract(Duration(days: 1));
//              log.w(
//                  "EntityRectangle Add Camera $entityId ${info.visibleFraction}");
            }

            if (info.visibleFraction <= 0.5 &&
                gd.activeCameras.containsKey(entityId)) {
              gd.activeCameras.remove(entityId);
//              log.e(
//                  "EntityRectangle Remove Camera $entityId ${info.visibleFraction}");
            }
          },
          child: InkWell(
            onTap: onTapCallback,
            onLongPress: onLongPressCallback,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          child: Stack(
                            fit: StackFit.expand,
                            alignment: Alignment.center,
                            children: <Widget>[
                              Image(
                                image: gd.getCameraThumbnailOld(entityId),
                                fit: BoxFit.cover,
                              ),
                              Image(
                                image: gd.getCameraThumbnail(entityId),
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: borderColor != Colors.transparent
                              ? borderColor
                              : ThemeInfo.colorBottomSheet.withOpacity(0.9),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Row(
                          children: <Widget>[
                            Text(
                              gd.entities[entityId].getOverrideName,
                              style: Theme.of(context).textTheme.body1,
                              textScaleFactor: gd.textScaleFactor,
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            Text(
                              "Last update: ${gd.timePassed(gd.getCameraLastUpdate(entityId))}",
                              style: Theme.of(context).textTheme.body1,
                              textScaleFactor: gd.textScaleFactor,
                            ),
                          ],
                        ),
                      ),
                    ],
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
