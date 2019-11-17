//class MyApp extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    gd = Provider.of<GeneralData>(context, listen: false);
//    log.w("Widget build MyApp");
//    SystemChrome.setPreferredOrientations([
//      DeviceOrientation.portraitUp,
//      DeviceOrientation.portraitDown,
//    ]);
//
////    return MaterialApp(
////      debugShowCheckedModeBanner: false,
////      theme: gd.currentTheme,
////      title: 'HassKit',
////      home: HomeView(),
////    );
//    return Selector<GeneralData, ThemeData>(
//      selector: (context, gdc) => gd.currentTheme,
//      builder: (context, data, child) {
//        return MaterialApp(
//          debugShowCheckedModeBanner: false,
//          theme: data,
//          title: 'HassKit',
//          home: HomeView(),
//        );
//      },
//    );
//  }
//}
