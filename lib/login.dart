import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ootw/splash.dart';
import 'home.dart';
import 'gender.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 460,
              child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(color: Color(0xFF76AEC7)),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text('오늘 날씨에 딱 맞는 ',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 20
                              ),
                            ),
                            Text('그 패션',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              child: Stack(
                                children: <Widget>[
                                  SizedBox(height:100,child: Image.asset('images/clouds.png',)),
                                  Column(
                                    children: <Widget>[
                                      SizedBox(height: 50,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 63,),
                                          InkWell(
                                            child: Text(
                                              'OOTW',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 45,
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => SplashScreen()));
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text(
                          'Outfit Of The Weather',
                          style:TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ]
              ),
            ),
            SizedBox(height: 20.0),
            _GoogleSignInSection(),
            _AnonymouslySignInSection(),
            SizedBox(height: 12.0),
            //_SignOutSection(),
          ],
        ),
      ),
    );
  }
}

class _SignOutSection extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _SignOutSectionState();
}

class _SignOutSectionState extends State<_SignOutSection>{
  Widget build(BuildContext context){
    return FlatButton(
      child: const Text('Sign out'),
      onPressed: () async {
        final FirebaseUser user = await _auth.currentUser();
        if (user == null) {
          Scaffold.of(context).showSnackBar(const SnackBar(
            content: Text('No one has signed in.'),
          ));
          return;
        }
        _signOut();
        final String uid = user.uid;
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(uid + ' has successfully signed out.'),
        ));
      },
    );
  }
  void _signOut() async {
    await _auth.signOut();
  }
}


class _AnonymouslySignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AnonymouslySignInSectionState();
}

class _AnonymouslySignInSectionState extends State<_AnonymouslySignInSection> {
  bool _success;
  String _userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          child:
          SizedBox(
            width: 330,
            child: Container(
              height: 50.0,
              child: GestureDetector(
                onTap: () async{
                  _signInAnonymously();
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xFF76AEC7),
                      style: BorderStyle.solid,
                      width: 1.0,
                    ),
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "로그인 없이 입장",
                          style: TextStyle(
                            color: Color(0xFF76AEC7),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            //letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
              /*
          RaisedButton(
            onPressed: () async {
              _signInAnonymously();
            },
            child: const Text('Sign in anonymously'),
          ),*/
        ),
      ],
    );
  }

  // Example code of how to sign in anonymously.
  void _signInAnonymously() async {
    final FirebaseUser user = (await _auth.signInAnonymously()).user;
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
      } else {
        _success = false;
      }
    });

    var document = await Firestore.instance.document('users/$_userID').get().then((doc) {
      if (doc.exists) {
        print(_userID);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage(user)));
      }
      else {
        print('new user');
        Firestore.instance.collection('users').document(user.uid).setData({
          'name': currentUser.displayName == null ? 'Anonymous' : user
              .displayName,
          'gender' : null,
          'favorite' : List<String>()
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => GenderPage(user)));
      }
    });
  }
}

class _GoogleSignInSection extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GoogleSignInSectionState();
}

class _GoogleSignInSectionState extends State<_GoogleSignInSection> {
  bool _success;
  String _userID;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          alignment: Alignment.center,
          child:
          SizedBox(
            width: 330,
            child: Container(
              height: 50.0,
              child: GestureDetector(
                onTap: () async{
                  _signInWithGoogle();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF76AEC7),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: Text(
                          "Google 로그인",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            //letterSpacing: 1,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          /*RaisedButton(
            onPressed: () async {
              _signInWithGoogle();
              if(_success != null){
                print('Successfully signed in, uid : '+_userID);
              }
            },
            child: const Text('Sign in with Google'),
          ),*/
        ),
      ],
    );
  }

  // Example code of how to sign in with google.
  void _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
    await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _success = true;
        _userID = user.uid;
      } else {
        _success = false;
      }
    });

    var document = await Firestore.instance.document('users/$_userID').get().then((doc) {
      if (doc.exists) {
        print(_userID);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => HomePage(user)));
      }
      else {
        print('new user');
        Firestore.instance.collection('users').document(user.uid).setData({
          'name': currentUser.displayName == null ? 'Anonymous' : user
              .displayName,
          'gender' : null,
          'favorite' : List<String>()
        });
        Navigator.push(context, MaterialPageRoute(builder: (context) => GenderPage(user)));
      }
    });

  }
}