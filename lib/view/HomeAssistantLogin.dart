import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:hasskit/helper/GeneralData.dart';
import 'package:hasskit/helper/Logger.dart';
import 'package:hasskit/helper/ThemeInfo.dart';

const kAndroidUserAgent =
    'Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/62.0.3202.94 Mobile Safari/537.36';

class HomeAssistantLogin extends StatelessWidget {
  HomeAssistantLogin({Key key, this.selectedUrl}) : super(key: key);

  final flutterWebViewPlugin = FlutterWebviewPlugin();
  final String selectedUrl;

  @override
  Widget build(BuildContext context) {
    void closePage() {
      Navigator.pop(context);
    }

    return MaterialApp(
      title: 'HassKit Login',
      theme: gd.currentTheme,
      routes: {
        '/': (_) => HomeAssistantLoginWebView(
              selectedUrl: selectedUrl,
              closePage: closePage,
            ),
        '/widget': (_) {
          return WebviewScaffold(
            url: selectedUrl,
            withZoom: true,
            withLocalStorage: true,
            hidden: true,
            initialChild: Column(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                SizedBox(height: 25),
                SpinKitThreeBounce(
                  size: 40,
                  color: ThemeInfo.colorIconActive,
                ),
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
                Container(
                  width: 100,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.pop(context, "Cancel Web Login Connection");
                    },
                    child: Text("Cancel"),
                  ),
                ),
                Expanded(
                  child: Container(),
                ),
              ],
            ),
          );
        },
      },
    );
  }
}

class HomeAssistantLoginWebView extends StatefulWidget {
  const HomeAssistantLoginWebView({Key key, this.selectedUrl, this.closePage})
      : super(key: key);
  final Function closePage;
  final String selectedUrl;

  @override
  _HomeAssistantLoginWebViewState createState() =>
      _HomeAssistantLoginWebViewState();
}

class _HomeAssistantLoginWebViewState extends State<HomeAssistantLoginWebView> {
  // Instance of WebView plugin
  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // On urlChanged stream
  StreamSubscription<String> _onUrlChanged;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    flutterWebViewPlugin.close();

    // Add a listener to on url changed
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      log.w('_onUrlChanged $url');
      if (url.contains('code=')) {
        var authCode = url.split('code=')[1];
        gd.sendHttpPost(gd.loginDataCurrent.getUrl, authCode, context);
        log.w('authCode [' + authCode + ']');
        widget.closePage();
      }
    });
  }

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onUrlChanged.cancel();
    flutterWebViewPlugin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(),
          ),
          Container(
            padding: EdgeInsets.all(32),
            child: Column(
              children: <Widget>[
                Text(
                  "Make sure the following info are correct",
                  textAlign: TextAlign.center,
                ),
                Text(
                  "http / https / address / port number",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "${gd.loginDataCurrent.url}",
                  style: Theme.of(context).textTheme.title,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/widget');
                      },
                      child: const Text('OK'),
                    ),
                    SizedBox(width: 8),
                    RaisedButton(
                      onPressed: () {
                        widget.closePage();
//                        Navigator.pop(context);
                      },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(),
          ),
        ],
      ),
    );
  }
}
