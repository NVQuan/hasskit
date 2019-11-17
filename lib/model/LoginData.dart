import 'package:hasskit/helper/Logger.dart';

class LoginData {
  String url;
  String longToken;
  String accessToken;
  int expiresIn;
  String refreshToken;
  String tokenType;
  int lastAccess;

  LoginData({
    this.url,
    this.accessToken,
    this.longToken,
    this.expiresIn,
    this.refreshToken,
    this.tokenType,
    this.lastAccess,
  });

  String get getUrl {
    if (url == null) {
      return "";
    }
    return url;
  }

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      url: "",
      accessToken: json['access_token'],
      longToken: "",
      expiresIn: json['expires_in'],
      refreshToken: json['refresh_token'],
      tokenType: json['token_type'],
      lastAccess: DateTime.now().toUtc().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'url': url,
        'accessToken': accessToken,
        'longToken': longToken,
        'expiresIn': expiresIn,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'lastAccess': lastAccess,
      };

  Duration get timeDurationSinceLastAccess {
    try {
      var totalDiff =
          DateTime.now().toUtc().millisecondsSinceEpoch - lastAccess;
      return Duration(milliseconds: totalDiff);
    } catch (e) {
      log.e("timeDurationSinceLastAccess $e");
      return Duration(
          milliseconds: DateTime.now().toUtc().millisecondsSinceEpoch);
    }
  }

  String get timeSinceLastAccess {
    var format =
        "${timeDurationSinceLastAccess.inDays}:${timeDurationSinceLastAccess.inHours.remainder(24)}:${timeDurationSinceLastAccess.inMinutes.remainder(60)}:${(timeDurationSinceLastAccess.inSeconds.remainder(60))}";
    var spit = format.split(":");
    var recVal = "";
    bool lessThanAMinute = true;

    var day = int.parse(spit[0]);
    var hour = int.parse(spit[1]);
    var minute = int.parse(spit[2]);
//    var second = int.parse(spit[3]);
    if (day > 365) {
      return "...";
    }
    if (day > 0) {
      String s = " day, ";
      if (day > 1) {
        s = " days, ";
      }
      recVal = recVal + day.toString() + s;
      lessThanAMinute = false;
    }
    if (hour > 0 || !lessThanAMinute) {
      String s = " hour, ";
      if (hour > 1) {
        s = " hours, ";
      }
      recVal = recVal + hour.toString() + s;
      lessThanAMinute = false;
    }
    if (minute > 0 || !lessThanAMinute) {
      String s = " minute";
      if (minute > 1) {
        s = " minutes ago";
      }
      recVal = recVal + minute.toString() + s;
      lessThanAMinute = false;
    }

    if (lessThanAMinute) {
      recVal = "less than a minute";
    }

    return recVal;
  }
}
