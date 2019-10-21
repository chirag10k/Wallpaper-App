import 'package:firebase/CRUD/crud_sample.dart';
import 'package:firebase/WallpaperApp/wall_screen.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {

  static FirebaseAnalytics analytics = new FirebaseAnalytics();
  static FirebaseAnalyticsObserver observer = new FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: new ThemeData(
        primarySwatch: Colors.yellow,
      ),
      navigatorObservers: <NavigatorObserver>[observer],
      home: new WallScreen(analytics: analytics, observer: observer),
    );
  }
}
