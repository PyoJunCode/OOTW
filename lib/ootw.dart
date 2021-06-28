import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'detail.dart';
import 'package:weather/weather_library.dart';
import 'module.dart';
import 'mlkit.dart';

class ootwPage extends StatefulWidget {

  final Weather weather;
  final FirebaseUser user;

  ootwPage(this.weather, this.user);

  @override
  _ootwPageState createState() => _ootwPageState();
}

class _ootwPageState extends State<ootwPage> {


  String selectedCate;
  String gender;
  int choice;

  @override
  initState() {
    super.initState();
    loadOotw();
  }

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: buildAppBar(),
      body: buildBody(context),
    );
  }

  Widget buildBody(BuildContext context){

    List<String> ootwList;
    setState(() {
       ootwList = loadOotw();
    });
    print(ootwList);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(5),),
            Stack(
              children: <Widget>[
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Color(0xFFEFEDED),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 10,),
                        Text('오늘의 OOTW는?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),),
                        SizedBox(height: 10,),
                        Expanded(
                          child: ListView.builder(
                                 itemCount: ootwList.length,
                                 itemBuilder: (BuildContext context, int index) {
                                   return Align(
                                     alignment: Alignment.centerLeft,
                                       child: ChoiceChip(
                                         selected: choice == index,
                                         label: Text('# '+ootwList[index],style: TextStyle(fontSize: 13, color: selectedCate == ootwList[index]? Colors.white : Colors.grey),),
                                         onSelected: (bool selected){
                                           setState(() {
                                             choice = selected ? index : null;
                                             selectedCate = ootwList[index];
                                           });
                                         },
                                         selectedColor: Colors.black87,
                                       ),
                                   );
                                 }),
                        )
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 25,
                  child: Image.asset('images/tshirt.png'),
                ),
                Positioned(
                  top: 124,
                  right: 40,
                  child: Image.asset('images/short.png'),
                ),
                Positioned(
                  bottom: 40,
                  right: 115,
                  child: Image.asset('images/shoes.png'),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Text(selectedCate == null ? '카테고리를 선택해 주세요.' : '\'$selectedCate\' 에 대한 검색 결과입니다.'),
            SizedBox(height: 8,),
            selectedCate == null?
            SizedBox(height: 260,):
            Container(
                height: 360,
                child: _buildCard(context)),
            SizedBox(height: 10),
            FlatButton(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(color: Color(0xFF76AEC7),)
              ),
              child: Text('이 장소에 딱 맞는 패션은?', style: TextStyle(color: Color(0xFF76AEC7)),), onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => mlPage(widget.weather,widget.user, gender),  fullscreenDialog: true));
            },),
          ],
        ),
      )
    );
  }
  Widget _buildCard(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('$gender의류').where('category', isEqualTo: selectedCate).snapshots(),
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
              child: Image.network(record.img)
          )
      )
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

  loadOotw() {

    Firestore.instance.collection('users').document(widget.user.uid).get().then((docSnap) {
        gender = docSnap['gender'];
        print(gender);
      assert(gender != null);
    });

    if(gender == '여성') {
      if (widget.weather.temperature.celsius >= 25)
        return ['티셔츠', '바지', '청바지'];
      else if (widget.weather.temperature.celsius < 25 &&
          widget.weather.temperature.celsius > 15)
        return ['카디건', '블라우스/셔츠', '점퍼', '바지', '청바지'];
    }
    else {
      if (widget.weather.temperature.celsius >= 25)
        return ['티셔츠', '바지', '청바지'];
      else if (widget.weather.temperature.celsius < 25 &&
          widget.weather.temperature.celsius > 15)
        return ['니트/스웨터', '셔츠/남방', '카디건', '바지', '청바지'];
    }
  }
}





