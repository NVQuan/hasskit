import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/ThemeInfo.dart';
import 'package:provider/provider.dart';

class EntityControlGeneral extends StatelessWidget {
  final String entityId;

  const EntityControlGeneral({@required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Selector<GeneralData, String>(
      selector: (_, generalData) =>
          "${generalData.entities[entityId].state}" +
          "${generalData.entities[entityId].getFriendlyName}" +
          "${generalData.entities[entityId].getOverrideIcon}",
      builder: (context, data, child) {
        var entity = gd.entities[entityId];
        return Container(
          child: Column(
            children: <Widget>[
              Icon(
                entity.mdiIcon,
                size: 200,
                color: ThemeInfo.colorIconActive,
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                gd.textToDisplay(entity.state),
                style: Theme.of(context).textTheme.title,
              ),
            ],
          ),
        );
      },
    );
  }
}
