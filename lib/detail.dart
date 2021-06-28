import 'dart:io';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'website.dart';
import 'package:weather/weather_library.dart';
import 'module.dart';

import 'ootw.dart';

//21800370
//0513 final

class detailPage extends StatefulWidget {


  //final FirebaseUser user;
  final Record product;
  final Weather weather;
  final FirebaseUser user;

  detailPage(this.product, this.weather, this.user);

  @override
  _detailPageState createState() => _detailPageState();
}

class _detailPageState extends State<detailPage> {

  final reference = Firestore.instance;
  Color fav_color;
  DocumentReference docRef;
  DocumentSnapshot doc;
  List favorite;

  Future<Color> set_color() async{
    docRef = Firestore.instance.collection('users').document(widget.user.uid);
    doc = await docRef.get();
    favorite = doc.data['favorite'];
    if(favorite.contains(widget.product.documentId)){
      return Colors.red;
    }else{
      return Colors.black;
    }
  }


  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }



  Widget buildBody(context){

    final likeit = SnackBar(content: Text('찜 목록에 추가되었습니다.'));

    return Builder(
      builder: (context) =>
       Padding(
        padding: const EdgeInsets.fromLTRB(8,8,0,30),
        child: Stack(
          children: <Widget>[
            Column(

            children: <Widget>[
              SizedBox(height: 30,),
              AspectRatio(
                aspectRatio: 18/11,
                child: Image.network(widget.product.img.split('?type')[0])
              ),

              SingleChildScrollView(
                child:
                   Container(
                    padding: EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[


                        ListTile(

                          title: Text(widget.product.name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),),

                        ),
//                Align(
//                    alignment: Alignment.centerLeft,
//                    child: Text('   \$ '+product['price'].toString(), style: TextStyle(color: Colors.blue, fontSize: 25),)),
                        Divider(thickness: 3,),
                        SizedBox(height: 10,),
                        Container(
                          height: 80,
                          child: Align(
                              alignment: Alignment.topRight,
                              child: Text(widget.product.price, style: TextStyle(fontSize: 20),)),
                        ),
                        FutureBuilder(
                            future: set_color(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData == false) {
                                return CircularProgressIndicator();
                              }else if(snapshot.hasError){
                                return Text('Error:{snapshot.error}');
                              }else{
                                fav_color=snapshot.data;
                                return Row(
                                  children: <Widget>[
                                    IconButton(color: fav_color, icon: Icon(Icons.favorite),onPressed: () async{
                                      DocumentReference docRef = Firestore.instance.collection('users').document(widget.user.uid);
                                      DocumentSnapshot doc = await docRef.get();
                                      List favorite = doc.data['favorite'];
                                      if(favorite.contains(widget.product.documentId)){
                                        setState(() {
                                          fav_color = Colors.black;
                                        });
                                        docRef.updateData(
                                            {'favorite': FieldValue.arrayRemove([widget.product.documentId])}
                                        );
                                      }else{
                                        setState(() {
                                          fav_color = Colors.red;
                                        });
                                        docRef.updateData(
                                            {'favorite': FieldValue.arrayUnion([widget.product.documentId])}
                                        );
                                      }
                                    },),
                                    IconButton(icon: Icon(Icons.shopping_basket,),onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => webview(widget.weather,widget.product.url)));
                                    })
                                  ],
                                );
                              }
                            }
                        )

                      ],
                    ),
                  ),
                ),
            ],
          ),

          ],
        ),
      ),
    );
  }

  Widget buildAppBar(){
    return AppBar(

      titleSpacing: 0.0,

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

  Future voteProduct() async {

    final reference = Firestore.instance;
    await reference.collection("users").document(widget.user.uid).updateData(
        {
          "favorite": FieldValue.arrayUnion([widget.product.documentId])
        }

    );

  }


}

