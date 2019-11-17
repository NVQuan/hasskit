import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  State<StatefulWidget> createState() => new MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  DeviceOrientation _currentOrientation;

  @override
  void initState() {
    super.initState();
    this._toggleOrientation();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'Current forced orientation is:',
            ),
            new Text(
              '$_currentOrientation',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _toggleOrientation,
        tooltip: 'Toggle Orientation',
        child: new Icon(Icons.add),
      ),
    );
  }

  void _toggleOrientation() {
    final newOrientation = _currentOrientation == DeviceOrientation.portraitUp
        ? DeviceOrientation.landscapeLeft
        : DeviceOrientation.portraitUp;
    SystemChrome.setPreferredOrientations([newOrientation]);
    setState(() => _currentOrientation = newOrientation);
  }
}
