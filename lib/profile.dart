import 'package:flutter/material.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseUser user;
  ProfilePage(this.user);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFD2F0F7),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.exit_to_app,
                semanticLabel: 'logout',
              ),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
          ],
        ),
        body: _loginInfo()
    );
  }
  _loginInfo(){
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 90,),
          SizedBox(
            width: 130,
            height: 130,
            child: Image.network(
              user.displayName!=null
              ?user.photoUrl
              :'http://handong.edu/site/handong/res/img/logo.png'
            ),
          ),
          SizedBox(
            height: 15,
          ),
          SizedBox(
            width: 300,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'UID',
                      style: TextStyle(fontSize:17, fontWeight:FontWeight.bold, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 7,),
                Text(
                  user.uid,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5,),
                Divider(color: Colors.black),
                SizedBox(height: 5,),
                Row(//name
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'name',
                      style: TextStyle(fontSize:17, fontWeight:FontWeight.bold, color: Colors.grey),
                    ),
                    SizedBox(width: 15,),
                    Text(
                      user.displayName!=null
                      ?user.displayName
                      :'Anonymous',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),
                SizedBox(height: 8,),
                Row(//email
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'email',
                      style: TextStyle(fontSize:17, fontWeight:FontWeight.bold, color: Colors.grey),
                    ),
                    SizedBox(width: 16,),
                    Text(
                      user.displayName!=null
                      ?user.email
                    :'Anonymous',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),

                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}

