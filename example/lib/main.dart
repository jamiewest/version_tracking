import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_tracking/version_tracking.dart';

void main() async {

  var preferences = await SharedPreferences.getInstance();
  var info = await PackageInfo.fromPlatform();

  runApp(MyApp(
    versionTracking: VersionTracking.from(preferences: preferences, info: info),
  ));
} 

class MyApp extends StatelessWidget {

  const MyApp({this.versionTracking});
  
  final VersionTracking versionTracking;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Text(versionTracking.toString())
            ],
          )
        )
      ),
    );
  }
}