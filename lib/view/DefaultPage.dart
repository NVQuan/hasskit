import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/MaterialDesignIcons.dart';

class DefaultPage extends StatelessWidget {
  final String error;

  const DefaultPage({@required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        child: Opacity(
          opacity: 0.5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                MaterialDesignIcons.getIconDataFromIconName(
                    "mdi:home-assistant"),
                size: 150,
              ),
              SizedBox(height: 20),
              Text(
                "Please Connect To\nHome Assistant",
                style: Theme.of(context).textTheme.title,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                error,
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.justify,
                maxLines: 3,
                textScaleFactor: gd.textScaleFactor,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ));
  }
}
