// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
//import 'package:uuid/uuid.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import 'dart:async';
import 'package:weather/weather_library.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  int type;
  HomePage(this.user, this.type);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map> pages = [
    {'id': 0,}, {'id': 1,},
  ];

  PageController pageController;
  int currentPage = 0;

  String key = '35557bb866e1fe9ca193680d9dd373de';
  WeatherStation ws;
  double lat =36.103315, lon=129.388426; //한동대 경도,위도

  static var now = DateTime.now();
  static final date1=now.add(Duration(days:1)),
  date2=now.add(Duration(days:2)),
  date3=now.add(Duration(days:3)),
  date4=now.add(Duration(days:4)),
  date5=now.add(Duration(days:5));

  final List dates =[
    DateFormat('EEEE').format(date1),
    DateFormat('EEEE').format(date2),
    DateFormat('EEEE').format(date3),
    DateFormat('EEEE').format(date4),
    DateFormat('EEEE').format(date5),
  ];

  Weather weather;
  double celsius;
  String country;
  List<Weather> forecasts;
  String descrip;
  String kor_descrip;
  double min_celsius;
  double max_celsius;
  DateTime sunrise;
  DateTime sunset;
  double pressure;
  double windSpeed;
  double windDegree;
  double humidity;
  double cloudiness;
  double rainLastHour;
  double snowLastHour;

  @override
  void initState(){
    super.initState();
    ws = new WeatherStation(key);
    pageController = PageController();
  }

  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  Future<List<Weather>> queryForecast() async {
    forecasts = await ws.fiveDayForecast(lat, lon);
    return forecasts;
  }

  Future<double> queryWeather() async{
    weather = await ws.currentWeather(lat, lon);
    celsius=weather.temperature.celsius;
    country=weather.areaName;
    descrip=weather.weatherMain;
    min_celsius=weather.tempMin.celsius;
    max_celsius=weather.tempMax.celsius;
    sunrise=weather.sunrise;
    sunset=weather.sunset;
    pressure=weather.pressure;
    windSpeed=weather.windSpeed;
    windDegree=weather.windDegree;
    humidity=weather.humidity;
    cloudiness=weather.cloudiness;
    rainLastHour=weather.rainLastHour;
    snowLastHour=weather.snowLastHour;
    return celsius;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xFFD2F0F7),
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: Color(0xffBBBBBB),
            semanticLabel: 'menu',
          ),
          onPressed: () {
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.person,
              color: Color(0xffBBBBBB),
              semanticLabel: 'profile',
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(widget.user, widget.type)));
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
  Widget _buildBody(){
    return Container(
      child: ListView(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            alignment: Alignment.center,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (selectedPage) {
                setState(() {
                  currentPage = selectedPage;
                });
              },
              itemCount: 2,
              itemBuilder: (context, position) {
                return Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    FadeInImage(
                      placeholder: AssetImage('images/clear_bg.png'),
                      image: AssetImage('images/clear_bg.png'),
                      fit: BoxFit.cover,
                    ),
                    Align(
                      child: Container(
                        margin: EdgeInsets.only(left: 30),
                        child: FutureBuilder(
                            future: queryWeather(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData == false) {
                                return CircularProgressIndicator();
                              }else if(snapshot.hasError){
                                return Text('Error:{snapshot.error}');
                              }else{
                                kor_descrip = translate_kor(descrip);
                                if(position==0){//1page
                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      SizedBox(
                                        width:140,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(DateFormat('HH:mm').format(now), style: TextStyle(fontSize: 17, color: Colors.grey),),
                                            Text(
                                              country, style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Colors.grey),
                                            ),
                                            SizedBox(
                                              width: 180,
                                              child: Row(
                                                children: <Widget>[
                                                  Text(snapshot.data.toStringAsFixed(0), style: TextStyle(fontSize:87,fontWeight:FontWeight.bold),),
                                                  SizedBox(width: 5,),
                                                  Column(
                                                    children: <Widget>[
                                                      Text('o', style: TextStyle(fontSize:20,fontWeight:FontWeight.bold),),
                                                      SizedBox(height: 60),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 7,),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 24,),
                                      SizedBox(width: 170,child:icon(descrip),),
                                      //SizedBox(width: 170, child: Image.asset('images/rain.png')),
                                    ],
                                  );
                                }else if(position==1){//2page
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: <Widget>[
                                          SizedBox(width: 30, child: Image.asset('images/clear.png')),
                                          SizedBox(width: 40,),
                                          SizedBox(
                                            width: 87,
                                            child:Row(
                                              children: <Widget>[
                                                Text('일출  '),
                                                Text(DateFormat("HH:mm").format(sunrise),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                              ],
                                            )
                                          ),
                                          SizedBox(width:50),
                                          Text('일몰  '),
                                          Text(DateFormat("HH:mm").format(sunset),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        ],
                                      ),
                                      SizedBox(height: 20,),
                                      Row(
                                        children: <Widget>[
                                          Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  SizedBox(width: 30, child: Image.asset('images/otherwise.png')),
                                                  SizedBox(width: 40,),
                                                  SizedBox(
                                                      width: 87,
                                                      child:Row(
                                                        children: <Widget>[
                                                          Text('풍속  '),
                                                          Text(windSpeed.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                        ],
                                                      )
                                                  ),
                                                  SizedBox(width:50),
                                                  Text('풍도  '),
                                                  Text(windDegree.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 70,),
                                          SizedBox(
                                              width: 87,
                                              child:Row(
                                                children: <Widget>[
                                                  Text('습도  '),
                                                  Text(humidity.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                                ],
                                              )
                                          ),
                                          SizedBox(width:50),
                                          Text('압력  '),
                                          Text(pressure.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        ],
                                      ),
                                      SizedBox(height: 7,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 70,),
                                          Text('운량  '),
                                          Text(cloudiness.toStringAsFixed(2),style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                        ],
                                      ),
                                    ],
                                  );
                                }else{//3page
                                  return Row(
                                    children: <Widget>[
                                      SizedBox(width: 30, child: Image.asset('images/rain.png')),
                                      Text('비예측'),
                                      Text(rainLastHour.toStringAsFixed(2)),
                                      SizedBox(width: 50,),
                                      SizedBox(width: 30, child: Image.asset('images/rain.png')),
                                      Text('눈예측'),
                                      Text(snowLastHour.toStringAsFixed(2)),
                                    ],
                                  );
                                }
                              }
                            }
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            height: 22,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Color(0xffE0E2E1),
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: pages.map((image) {
                    return GestureDetector(
                      onTap: () {
                        currentPage = image['id'];
                        pageController.jumpToPage(currentPage);
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        width: currentPage == image['id'] ? 14 : 8,
                        height: currentPage == image['id'] ? 14 : 8,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                currentPage == image['id'] ? 7 : 4),
                            color: Colors.grey
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: EdgeInsets.only(top: 28, left: 25),
                    child: FutureBuilder(//5일날짜
                        future: queryForecast(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData == false) {
                            return CircularProgressIndicator();
                          }else if(snapshot.hasError){
                            return Text('Error:{snapshot.error}');
                          }else{
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(DateFormat('MM.dd EEE').format(now), style: TextStyle(fontSize: 17, color: Colors.grey),),
                                SizedBox(height: 7,),
                                Text(kor_descrip, style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),),
                                //Text('햇살이 따뜻한 맑은 날', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),),
                                Container(
                                  margin: EdgeInsets.only(top: 17, left: 8),
                                  child: Column(
                                    children: <Widget>[
                                      Row(//내일
                                        children: <Widget>[
                                          SizedBox(
                                            width: 40,
                                            child: icon(snapshot.data[5].weatherMain.toString()),
                                          ),
                                          SizedBox(width: 10,),
                                          SizedBox(
                                              width:120,
                                              child: Text(dates[0], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffBBBBBB)),)),
                                          SizedBox(width: 67,),
                                          SizedBox(
                                            width:25,
                                            child: Text(snapshot.data[1].tempMin.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width:10,child: Text('/')),
                                          SizedBox(
                                            width:23,
                                            child: Text(snapshot.data[5].tempMax.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 40,
                                            child: icon(snapshot.data[13].weatherMain.toString()),
                                          ),
                                          SizedBox(width: 10,),
                                          SizedBox(
                                              width:120,
                                              child: Text(dates[1], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffBBBBBB)),)),
                                          SizedBox(width: 67,),
                                          SizedBox(
                                            width:25,
                                            child: Text(snapshot.data[9].tempMin.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width:10,child: Text('/')),
                                          SizedBox(
                                            width:23,
                                            child: Text(snapshot.data[13].tempMax.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 40,
                                            child: icon(snapshot.data[21].weatherMain.toString()),
                                          ),
                                          SizedBox(width: 10,),
                                          SizedBox(
                                              width:120,
                                              child: Text(dates[2], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffBBBBBB)),)),
                                          SizedBox(width: 67,),
                                          SizedBox(
                                            width:25,
                                            child: Text(snapshot.data[17].tempMin.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width:10,child: Text('/')),
                                          SizedBox(
                                            width:23,
                                            child: Text(snapshot.data[21].tempMax.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 40,
                                            child: icon(snapshot.data[29].weatherMain.toString()),
                                          ),
                                          SizedBox(width: 10,),
                                          SizedBox(
                                              width:120,
                                              child: Text(dates[3], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffBBBBBB)),)),
                                          SizedBox(width: 67,),
                                          SizedBox(
                                            width:25,
                                            child: Text(snapshot.data[25].tempMin.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width:10,child: Text('/')),
                                          SizedBox(
                                            width:23,
                                            child: Text(snapshot.data[29].tempMax.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 15,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 40,
                                            child: icon(snapshot.data[37].weatherMain.toString()),
                                          ),
                                          SizedBox(width: 10,),
                                          SizedBox(
                                              width:120,
                                              child: Text(dates[4], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xffBBBBBB)),)),
                                          SizedBox(width: 67,),
                                          SizedBox(
                                            width:25,
                                            child: Text(snapshot.data[33].tempMin.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width:10,child: Text('/')),
                                          SizedBox(
                                            width:23,
                                            child: Text(snapshot.data[37].tempMax.toString().substring(0,2),
                                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          }
                        }
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Image.asset('images/outfit_button.png'),
                      iconSize: 9,
                      onPressed: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  String translate_kor(String descrip){
    if(descrip=='Clouds'){
      return '뭉게뭉게 구름 핀 흐린 날';
    }
    else if(descrip=='Clear'){
      return '햇살이 따뜻한 맑은 날';
    }
    else if(descrip=='Rain'){
      return '주륵주륵 비오는 날';
    }
    else{
      return '살짝 구름핀 날';
    }
  }

  Widget icon(String descrip){
    if(descrip=='Clouds'){
      return Image.asset('images/clouds.png');
    }
    else if(descrip=='Clear'){
      return Image.asset('images/clear.png');
    }
    else if(descrip=='Rain'){
      return Image.asset('images/rain.png');
    }
    else{
      return Image.asset('images/otherwise.png');
    }
  }
}