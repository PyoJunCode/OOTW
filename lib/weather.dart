/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ootw/ootw.dart';
import 'dart:async';
import 'package:weather/weather_library.dart';

enum AppState { NOT_DOWNLOADED, DOWNLOADING, FINISHED_DOWNLOADING }

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String key = '856822fd8e22db5e1ba48c0e7d69844a';
  WeatherStation ws;
  List<Weather> _data = [];
  AppState _state = AppState.NOT_DOWNLOADED;
  double lat, lon;
  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ws = new WeatherStation(key);
  }

  void queryForecast() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _state = AppState.DOWNLOADING;
    });

    List<Weather> forecasts = await ws.fiveDayForecast(lat, lon);
    setState(() {
      _data = forecasts;
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  void queryWeather() async {
    /// Removes keyboard
    FocusScope.of(context).requestFocus(FocusNode());

    setState(() {
      _state = AppState.DOWNLOADING;
    });

    Weather weather = await ws.currentWeather(lat, lon);
    setState(() {
      _data = [weather];
      _state = AppState.FINISHED_DOWNLOADING;
    });
  }

  Widget contentFinishedDownload() {
    return Center(
      child: ListView.separated(
        itemCount: _data.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_data[index].toString()),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
      ),
    );
  }

  Widget contentDownloading() {
    return Container(
        margin: EdgeInsets.all(25),
        child: Column(children: [
          Text(
            'Fetching Weather...',
            style: TextStyle(fontSize: 20),
          ),
          Container(
              margin: EdgeInsets.only(top: 50),
              child: Center(child: CircularProgressIndicator(strokeWidth: 10)))
        ]));
  }

  Widget contentNotDownloaded() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Press the button to download the Weather forecast',
          ),
        ],
      ),
    );
  }

  Widget _resultView() => _state == AppState.FINISHED_DOWNLOADING
      ? contentFinishedDownload()
      : _state == AppState.DOWNLOADING
      ? contentDownloading()
      : contentNotDownloaded();

  void _saveLat(String input) {
    lat = double.tryParse(input);
    print(lat);
  }

  void _saveLon(String input) {
    lon = double.tryParse(input);
    print(lon);
  }

  Widget _latTextField() {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: EdgeInsets.all(10),
        child: TextField(
            controller: _latController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter longitude'),
            keyboardType: TextInputType.number,
            onChanged: _saveLat,
            onSubmitted: _saveLat));
  }

  Widget _lonTextField() {
    return Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor))),
        padding: EdgeInsets.all(10),
        child: TextField(
            controller: _lonController,
            decoration: InputDecoration(
                border: OutlineInputBorder(), hintText: 'Enter longitude'),
            keyboardType: TextInputType.number,
            onChanged: _saveLon,
            onSubmitted: _saveLon));
  }

  Widget _weatherButton() {
    return FlatButton(
      child: Text('Fetch weather'),
      onPressed: queryWeather,
      color: Colors.blue,
    );
  }

  Widget _forecastButton() {
    return FlatButton(
      child: Text('Fetch forecast'),
      onPressed: queryForecast,
      color: Colors.blue,
    );
  }

  Widget _ootwButton() {
    return FlatButton(
      child: Text('get Current Position'),
      onPressed: (){
        //Navigator.push(context, MaterialPageRoute(builder: (context) => ootwPage()));
      },
      color: Colors.blue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('Weather Example App'),
            ),
            body: Column(
              children: <Widget>[
                _latTextField(),
                _lonTextField(),
                _weatherButton(),
                _forecastButton(),
          FlatButton(
            child: Text('get Current Position'),
            onPressed: () async {
              Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
              print(position.latitude.toString());
              print(position.longitude.toString());
              setState(() {
                _latController.text = position.latitude.toString();
                _lonController.text = position.longitude.toString();
                lat = position.latitude;
                lon =  position.longitude;
              });
            },
            color: Colors.blue,
          ),

                Text(
                  'Output:',
                  style: TextStyle(fontSize: 20),
                ),
                Divider(
                  height: 20.0,
                  thickness: 2.0,
                ),
                Expanded(child: _resultView())
              ],
            )),
      ),
    );
  }
}