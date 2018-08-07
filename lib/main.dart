import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';

Future<void> main() async {
  final FirebaseApp app = await FirebaseApp.configure(
    name: 'db2',
    options: Platform.isIOS
        ? const FirebaseOptions(
            googleAppID: '1:293093685027:ios:2f2c546ee9687a7c',
            // gcmSenderID: '297855924061',
            databaseURL: 'https://mackenzies-books.firebaseio.com',
          )
        : const FirebaseOptions(
            googleAppID: '1:293093685027:android:2f2c546ee9687a7c',
            apiKey: 'AIzaSyCAWBiq0WSctBEUYaXIdM_3lYsYIm3CR9k',
            databaseURL: 'https://mackenzies-books.firebaseio.com',
          ),
  );
  runApp(new MaterialApp(
    title: "Mackenzie's Books",
    home: new MyHomePage(app: app),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.app});
  final FirebaseApp app;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter;
  DatabaseReference _counterRef;
  DatabaseReference _booksRef;
  StreamSubscription<Event> _counterSubscription;
  StreamSubscription<Event> _bookSubscription;
  bool _anchorToBottom = false;

  DatabaseError _error;

  @override
  void initState() {
    super.initState();
    // Demonstrates configuring the database directly
    final FirebaseDatabase database = new FirebaseDatabase(app: widget.app);
    _booksRef = database.reference().child('books');
    // database.reference().child('books').once().then((DataSnapshot snapshot) {
    //   print('Connected to second database and read ${snapshot.value}');
    // });
    database.setPersistenceEnabled(true);
    database.setPersistenceCacheSizeBytes(10000000);
    _booksRef.keepSynced(true);
    _bookSubscription = _booksRef.limitToFirst(10).onValue.listen((Event event) {
      setState(() {
        _error = null;
        _counter = event.snapshot.value ?? 0;
      });
    }, onError: (Object o) {
      final DatabaseError error = o;
      setState(() {
        _error = error;
      });
    });
    // _messagesSubscription =
    //     _messagesRef.limitToLast(10).onChildAdded.listen((Event event) {
    //   print('Child added: ${event.snapshot.value}');
    // }, onError: (Object o) {
    //   final DatabaseError error = o;
    //   print('Error: ${error.code} ${error.message}');
    // });
  }

  @override
  void dispose() {
    super.dispose();
    _bookSubscription.cancel();
    _counterSubscription.cancel();
  }

  // Future<Null> _increment() async {
  //   // Increment counter in transaction.
  //   final TransactionResult transactionResult =
  //       await _counterRef.runTransaction((MutableData mutableData) async {
  //     mutableData.value = (mutableData.value ?? 0) + 1;
  //     return mutableData;
  //   });

  //   if (transactionResult.committed) {
  //     _booksRef.push().set(<String, String>{
  //       _kTestKey: '$_kTestValue ${transactionResult.dataSnapshot.value}'
  //     });
  //   } else {
  //     print('Transaction not committed.');
  //     if (transactionResult.error != null) {
  //       print(transactionResult.error.message);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Flutter Database Example'),
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new FirebaseAnimatedList(
              key: new ValueKey<bool>(_anchorToBottom),
              query: _booksRef,
              reverse: _anchorToBottom,
              sort: _anchorToBottom
                  ? (DataSnapshot a, DataSnapshot b) => b.key.compareTo(a.key)
                  : null,
              itemBuilder: (BuildContext context, DataSnapshot snapshot,
                  Animation<double> animation, int index) {
                    String imageUrl;
                    // String title;
                    imageUrl = snapshot.value['imageURL'];
                    // title = snapshot.value['title'];
                return new SizeTransition(
                  sizeFactor: animation,
                  child: new Image.network(imageUrl),
                  // child: new Text("$title: ${snapshot.value.toString()}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}