import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class CrudSample extends StatefulWidget {
  @override
  _CrudSampleState createState() => _CrudSampleState();
}

class _CrudSampleState extends State<CrudSample> {
  String myText = null;
  StreamSubscription<DocumentSnapshot> subscription;

  final DocumentReference documentReference= Firestore.instance.document("myData/dummy");

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = new GoogleSignIn();

  Future<FirebaseUser> _signIn() async{
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: gSA.idToken, accessToken: gSA.accessToken);
    final FirebaseUser user = (await _auth.signInWithCredential(credential)) as FirebaseUser;

    print("User Name : ${user.displayName}");
    return user;

  }

  void _signOut(){
    googleSignIn.signOut();
    print("User Signed Out");
  }

  void _add(){
    Map<String, String> data = <String, String>{
      "name" : "Chirag Saraogi",
      "desc" : "Student",
    };
    documentReference.setData(data).whenComplete((){
      print("Document Added");
    }).catchError((e)=>print(e));
  }

  void _update(){
    Map<String, String> data = <String, String>{
      "name" : "Chirag Saraogi Updated",
      "desc" : "Student Updated",
    };
    documentReference.updateData(data).whenComplete((){
      print("Document Updated");
    }).catchError((e)=>print(e));
  }

  void _delete(){
    documentReference.delete().whenComplete((){
      print("Deleted Successfully");
      setState(() {});
    }).catchError((e)=>print(e));
  }

  void _fetch(){
    documentReference.get().then((datasnapshot){
      setState(() {
        if(datasnapshot.exists){
          myText = datasnapshot.data['desc'];
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    subscription = documentReference.snapshots().listen((datasnapshot){
      setState(() {
        if(datasnapshot.exists){
          myText = datasnapshot.data['desc'];
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Firebase Demo"),
      ),
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new RaisedButton(
              onPressed: () => _signIn()
                  .then((FirebaseUser user)=>print(user))
                  .catchError((e)=>print(e)),
              child: new Text("Sign in"),
              color: Colors.green,
            ),
            new Padding(
              padding: const EdgeInsets.all(20.0),
            ),
            new RaisedButton(
              onPressed: _signOut,
              child: new Text("Sign out"),
              color: Colors.red,
            ),
            new Padding(
              padding: const EdgeInsets.all(20.0),
            ),
            new RaisedButton(
              onPressed: _add,
              child: new Text("Add"),
              color: Colors.cyan,
            ),
            new Padding(
              padding: const EdgeInsets.all(20.0),
            ),
            new RaisedButton(
              onPressed: _update,
              child: new Text("Update"),
              color: Colors.lightBlue,
            ),
            new Padding(
              padding: const EdgeInsets.all(20.0),
            ),
            new RaisedButton(
              onPressed: _delete,
              child: new Text("Delete"),
              color: Colors.orange,
            ),
            new Padding(
              padding: const EdgeInsets.all(20.0),
            ),
            new RaisedButton(
              onPressed: _fetch,
              child: new Text("Fetch"),
              color: Colors.lime,
            ),
            new Padding(
              padding: const EdgeInsets.all(20.0),
            ),
            myText == null
                ? new Container()
                : new Text(
                myText,
                style: new TextStyle(fontSize: 20.0)
            ),
          ],
        ),
      ),
    );
  }
}