import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewLoginPage extends StatefulWidget {
  @override
  _WebViewLoginPageState createState() => _WebViewLoginPageState();
}

class _WebViewLoginPageState extends State<WebViewLoginPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    String initialUrl = gd.loginDataCurrent.getUrl +
        '/auth/authorize?client_id=' +
        gd.loginDataCurrent.getUrl +
        "/hasskit" '&redirect_uri=' +
        gd.loginDataCurrent.getUrl +
        "/hasskit";
//    initUrl = Uri.encodeComponent(initUrl);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 36),
          gd.webViewLoading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 25),
                    CircularProgressIndicator(),
                    SizedBox(height: 25),
                    Text(
                      "Connecting to",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25),
                    Text(
                      "${gd.loginDataCurrent.getUrl}",
                      style: Theme.of(context).textTheme.title,
                      textAlign: TextAlign.center,
                      maxLines: 10,
                    ),
                    SizedBox(height: 25),
                    Text(
                      "Make sure the following info are correct",
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "http / https / port number",
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 25),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context, "Cancel Web Login Connection");
                      },
                      child: Text("Cancel"),
                    )
                  ],
                )
              : Container(),
          Expanded(
            child: WebView(
              debuggingEnabled: true,
              initialUrl: initialUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
                log.d('onWebViewCreated ${_controller.isCompleted}');
                setState(() {});
              },
              onPageFinished: (finishedString) {
                gd.webViewLoading = false;
                log.d('onPageFinished finishedString $finishedString');
                if (finishedString.contains('code=')) {
                  var authCode = finishedString.split('code=')[1];
                  gd.sendHttpPost(
                      gd.loginDataCurrent.getUrl, authCode, context);
                  log.d('authCode [' + authCode + ']');
                  log.d('Navigator.pop(context)');
                }
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}
