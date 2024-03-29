import 'package:firebase/WallpaperApp/fullscreen_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

const String testDevice = '';

class WallScreen extends StatefulWidget {

  final FirebaseAnalytics analytics;
  final FirebaseAnalyticsObserver observer;

  WallScreen({this.analytics, this.observer});

  @override
  _WallScreenState createState() => new _WallScreenState();
}

class _WallScreenState extends State<WallScreen> {

  static final MobileAdTargetingInfo targetInfo = new MobileAdTargetingInfo(
    testDevices: <String>[] ,
    keywords: <String>['wallpapers','wall','amoled','tv shows'],
    birthday: new DateTime.now(),
    childDirected: true,
  );

  BannerAd _bannerAd;
  InterstitialAd _interstitialAd;

  StreamSubscription<QuerySnapshot> subscription;
  List<DocumentSnapshot> wallpapersList;
  final CollectionReference collectionReference =
  Firestore.instance.collection("wallpapers");

  BannerAd createBannerAd(){
    return new BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      size: AdSize.banner,
      targetingInfo: targetInfo,
      listener: (MobileAdEvent event) {
        print("Banner Event: $event");
      }
    );
  }

  InterstitialAd createInterstitialAd(){
    return new InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetInfo,
      listener: (MobileAdEvent event) {
        print("Interstitial Event: $event");
      }
    );
  }

  Future<Null> _currentScreen() async{
    await widget.analytics
      .setCurrentScreen(screenName: 'Wall Screen', screenClassOverride: 'WallScreen');
  }

  Future<Null> _sendAnalytics() async{
    await widget.analytics
      .logEvent(name: "Tap to full screen", parameters: <String, dynamic>{});
  }

  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-3930233358914686~1833302134");
    _bannerAd = createBannerAd()..load()..show();
    subscription = collectionReference.snapshots().listen((datasnapshot) {
      setState(() {
        wallpapersList = datasnapshot.documents;
      });
    });

    _currentScreen();

  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Wallfy",
            style: new TextStyle(
                color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: wallpapersList != null
            ? new StaggeredGridView.countBuilder(
          padding: const EdgeInsets.all(8.0),
          crossAxisCount: 4,
          itemCount: wallpapersList.length,
          itemBuilder: (context, i) {
            String imgPath = wallpapersList[i].data['url'];
            return new Material(
              elevation: 8.0,
              borderRadius:
              new BorderRadius.all(new Radius.circular(8.0)),
              child: new InkWell(
                onTap: () {
                  _sendAnalytics();
                  _interstitialAd = createInterstitialAd()..load()..show();
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                          builder: (context) =>
                          new FullScreenImagePage(imgPath)));
                },
                child: new Hero(
                  tag: imgPath,
                  child: new FadeInImage(
                    image: new NetworkImage(imgPath),
                    fit: BoxFit.cover,
                    placeholder: new AssetImage("assets/wallfy.png"),
                  ),
                ),
              ),
            );
          },
          staggeredTileBuilder: (i) =>
          new StaggeredTile.count(2, i.isEven ? 2 : 3),
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 8.0,
        )
          : new Center(
            child: new CircularProgressIndicator(),
        ));
  }
}