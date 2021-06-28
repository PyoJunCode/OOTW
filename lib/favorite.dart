import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'detail.dart';
import 'package:weather/weather_library.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'module.dart';


class FavoritePage extends StatefulWidget {

  final Weather weather;
  final FirebaseUser user;
  FavoritePage(this.weather, this.user);

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {

  DocumentReference docRef;
  DocumentSnapshot doc;
  List favorite;
  String gender;
  var items;

  Future<List> get_list() async{
    docRef = Firestore.instance.collection('users').document(widget.user.uid);
    doc = await docRef.get();
    favorite = doc.data['favorite'];
    gender = doc.data['gender'];
    return favorite;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }
  
  Widget buildBody(){
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SizedBox(height: 30,),
          Container(
            child: Center(
              child: Column(
                children: <Widget>[
                  Text('❤', style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        widget.user.displayName!=null
                            ?widget.user.displayName+'님의'
                            :'익명님의',
                        style: TextStyle(fontSize: 15),),
                      SizedBox(width: 8,),
                      Text('찜 ', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                      Text('리스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18,),
          Container(
            height: 800,
            child: FutureBuilder(
              future: get_list(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData == false) {
                  return CircularProgressIndicator();
                }else if(snapshot.hasError){
                  return Text('Error:{snapshot.error}');
                }else{
                  items = snapshot.data;
                  return StreamBuilder(
                    stream: Firestore.instance.collection('users').snapshots(),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if(!snapshot.hasData){
                        return Center(child: CircularProgressIndicator(),);
                      }
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.0,
                          mainAxisSpacing: 1.0,
                          crossAxisSpacing: 1.0
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, index){
                          return buildListItem(context, items[index]);
                        },
                      );
                    },
                  );
                }
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListItem(context, document){
    Record record;
    String col_name;
    if(gender=='여성'){col_name = '여성의류';}
    else{col_name = '남성의류';}
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection(col_name).where('docID', isEqualTo: document).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
        if (!snapshot.hasData) return LinearProgressIndicator();
        List result = snapshot.data.documents.map((e){
          record = Record.fromSnapshot(e);
          return e.data;
        }).toList();
        return Material(
          child: InkWell(
            onTap:() => Navigator.push(context, MaterialPageRoute(builder: (context) => detailPage(record,widget.weather,widget.user))),
            child: Image.network(
              result[0]['img'].toString(),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  Widget buildAppBar(){
    return AppBar(
      //automaticallyImplyLeading: false,
      titleSpacing: 0.0,
      //leading: Container(),
      backgroundColor: Color(0xFFD2F0F7),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.weather.areaName, style: TextStyle(color: Color(0xFF5F5B5B)),),
          ),
          SizedBox(width: 50,),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: <Widget>[

                Text(widget.weather.temperature.celsius.toStringAsFixed(0), style: TextStyle(color: Colors.black,fontSize:40,fontWeight:FontWeight.bold),),
                SizedBox(width: 5,),
                Column(
                  children: <Widget>[
                    Text('o', style: TextStyle(color: Colors.black,fontSize:20,fontWeight:FontWeight.bold),),
                    SizedBox(height: 30),
                  ],
                ),
                SizedBox(
                    width: 60,
                    child:icon(widget.weather.weatherMain))
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[

      ],
    );

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

