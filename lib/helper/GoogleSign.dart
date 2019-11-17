import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hasskit/helper/Logger.dart';
import 'GeneralData.dart';
import 'ThemeInfo.dart';

GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
//    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class GoogleSign extends StatefulWidget {
  @override
  _GoogleSignState createState() => _GoogleSignState();
}

class _GoogleSignState extends State<GoogleSign> {
  @override
  void initState() {
    super.initState();
//    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
//      setState(() {
//        gd.firebaseCurrentUser = account;
//      });
//    });
//    _googleSignIn.signInSilently();
  }

  Future<void> _handleSignIn() async {
    try {
      log.d("googleSignIn.signIn()");
      await googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleSignOut() async {
    googleSignIn.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildListDelegate(
        [
          Container(
            padding: EdgeInsets.all(8),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                  color: ThemeInfo.colorBottomSheet.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  gd.googleSignInAccount != null
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(gd.googleSignInAccount.photoUrl),
                          backgroundColor: Colors.transparent,
                          radius: 44,
                        )
                      : CircleAvatar(
                          backgroundImage:
                              AssetImage("assets/images/google_cloud.png"),
                          backgroundColor: Colors.transparent,
                          radius: 44,
                        ),
                  gd.googleSignInAccount != null
                      ? Text(gd.googleSignInAccount.displayName ?? '')
                      : Text('Use Cloud Data Sync'),
//                  Text(_currentUser.email ?? ''),
//                  Text('Using Cloud Sync Data'),
                  gd.googleSignInAccount != null
                      ? RaisedButton(
                          child: Text("Sign Out"),
                          onPressed: _handleSignOut,
//                    shape: RoundedRectangleBorder(
//                      borderRadius: new BorderRadius.circular(18.0),
//                      side: BorderSide(color: Colors.red),
//                    ),
                        )
                      : RaisedButton(
                          child: Text("Sign In"),
                          onPressed: _handleSignIn,
//                    shape: RoundedRectangleBorder(
//                      borderRadius: new BorderRadius.circular(18.0),
//                      side: BorderSide(color: Colors.red),
//                    ),
                        ),
                  Text(
                    "Keep your rooms layout and device custumization synchronized accross devices. HassKit won't upload your login data online...",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
