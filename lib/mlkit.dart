import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather/weather_library.dart';
import 'module.dart';
import 'detail.dart';

class mlPage extends StatefulWidget {

  final Weather weather;
  final FirebaseUser user;
  final String gender;

  mlPage(this.weather, this.user, this.gender);

  @override
  _mlPageState createState() => _mlPageState();
}

class _mlPageState extends State<mlPage> {


  File _image;
  bool imgLoaded = false;
  List<ImageLabel> cloudLabels;
  String selected = '';
  String place = '';
  String item = '';

  final picker = ImagePicker();
  final BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
  final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
  final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
  final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
  final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();

  @override
  Widget build(BuildContext context) {

    File _image;


    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(),
    );
  }

  Widget buildBody(){




    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,

      children: <Widget>[
        AspectRatio(
          aspectRatio: 18/11,
          child: _image != null ? Image.asset(_image.path,fit: BoxFit.fitWidth,) : Image.network("http://handong.edu/site/handong/res/img/logo.png"),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
             getImageFile();
            },
          ),
        ),
        imgLoaded?
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: cloudLabels.length,
              itemBuilder: (BuildContext context, int index) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(

                    child: FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: BorderSide(color:Color(0xFF76AEC7),)
                      ),
                      splashColor: Colors.blueAccent,
                      child: Text('#'+cloudLabels[index].text,style: TextStyle(fontSize: 13, color: selected == cloudLabels[index].text? Colors.black : Colors.grey),),
                      onPressed: () {
                        setState(() {
                          selected = cloudLabels[index].text;
                        });
                      },),
                  ),
                );

              }),
        )
            :
            Text('배경을 선택하세요!'),
        SizedBox(height: 10,),
        imgLoaded?
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$place',style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.bold),),
                Text(' 에 갈 땐 '),
                Text('$item',style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.bold),),
                Text(' 필수!'),
              ],
            ),
            Container(
                height: 360,
                child: _buildCard(context)),
          ],
        )
        :
        Container(),
      ],
    );

  }

  Widget buildAppBar() {
    return AppBar(

      titleSpacing: 0.0,

      backgroundColor: Color(0xFFD2F0F7),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.weather.areaName,
              style: TextStyle(color: Color(0xFF5F5B5B)),),
          ),
          SizedBox(width: 50,),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: <Widget>[

                Text(widget.weather.temperature.celsius.toStringAsFixed(0),
                  style: TextStyle(color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold),),
                SizedBox(width: 5,),
                Column(
                  children: <Widget>[
                    Text('o', style: TextStyle(color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),),
                    SizedBox(height: 30),
                  ],
                ),
                SizedBox(
                    width: 60,
                    child: icon(widget.weather.weatherMain))
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
      ],
    );
  }


  Future getImageFile() async {
    final image = await picker.getImage(source: ImageSource.gallery);

      setState(() {
        _image = File(image.path);

      });

      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);

    //cloudLabels = await cloudLabeler.processImage(visionImage);
    cloudLabels = await labeler.processImage(visionImage);

    setState(() {
      imgLoaded = true;

    });


    for (ImageLabel label in cloudLabels) {
      final String text = label.text;
      loadOotp(label.text);
      print(text );

    }

    cloudLabeler.close();
  
  }
  Widget _buildCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('${widget.gender}의류').where('category', isEqualTo: item).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        //return _buildList(context, snapshot.data.documents);
        return GridView.count(
          crossAxisCount: 3,
          //padding: EdgeInsets.all(16.0),
          //childAspectRatio: 8.0 / 9.0,
          children: _buildList(context,snapshot.data.documents),
        );
      },
    );
  }



  List<Card> _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return snapshot.map((data) => _buildListItem(context, data)).toList();

  }

  Card _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);

    return Card(
        clipBehavior: Clip.antiAlias,

        child: InkWell(
            onTap:() => Navigator.push(context, MaterialPageRoute(builder: (context) => detailPage(record,widget.weather,widget.user))),
            child: Container(
                child: Hero(
                    tag : record.name,
                    child: Image.network(record.img))
            )
        )
    );
  }

  loadOotp(String label){
    if(label == 'Desert'){
      setState(() {
        place = '사막';
        item = '바지';
      });
    }
    else if(label == 'Beach'){
      setState(() {
        place = '바다';
        item = '비치웨어';
      });
    }
    else if(label == 'Marriage'){
      setState(() {
        place = '결혼식';
        item = '정장세트';
      });
    }

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


