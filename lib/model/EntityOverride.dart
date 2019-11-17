import 'package:hasskit/helper/Logger.dart';

class EntityOverride {
  String friendlyName;
  String icon;
  bool openRequireAttention;

  EntityOverride({this.friendlyName, this.icon, this.openRequireAttention});
  factory EntityOverride.fromJson(Map<String, dynamic> json) {
    try {
      return EntityOverride(
        friendlyName: json['friendlyName'],
        icon: json['icon'],
        openRequireAttention: json['openRequireAttention'],
      );
    } catch (e) {
      log.e("EntityOverride.fromJson $e");
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'friendlyName': friendlyName,
        'icon': icon,
        'openRequireAttention': openRequireAttention,
      };
}
