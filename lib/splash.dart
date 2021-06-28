import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState(){
    super.initState();
    Timer(Duration(seconds:3),(){
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Color(0xFF76AEC7)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 160,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        SizedBox(height:80,child: Image.asset('images/clouds.png',)),
                        Column(
                          children: <Widget>[
                            SizedBox(height: 40,),
                            Row(
                              children: <Widget>[
                                SizedBox(width: 53,),
                                Text(
                                  'OOTW',
                                  style: TextStyle(
                                    //color: Color(0xFFFFB600),
                                    color: Colors.white,
                                    fontSize: 35,
                                    fontWeight: FontWeight.bold
                                  ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('오늘 날씨에 딱 맞는 ',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16
                    ),
                  ),
                  Text('그 패션',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              SizedBox(height: 190,),
              Text('# Outfit_Of_The_Weather',
                style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12
                ),
              ),
              SizedBox(height: 10,),
              Text(
                "@ JYP",
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
