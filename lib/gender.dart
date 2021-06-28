import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GenderPage extends StatefulWidget {
  final FirebaseUser user;
  GenderPage(this.user);
  @override
  _GenderPageState createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {

  String boy = 'images/boy.png';
  String girl = 'images/girl.png';
  String boy_selected = 'images/boy_selected.png';
  String girl_selected = 'images/girl_selected.png';

  String url1 = 'images/boy.png';
  String url2 = 'images/girl.png';

  String gender;
  String message='';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'select gender',
      home: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              SizedBox(height: 150,),
              Text('성별선택', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),),
              SizedBox(height: 10,),
              Text('성별에 맞는 옷 추천해드릴게요!', style: TextStyle(fontSize: 16),),
              SizedBox(height: 100,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  InkWell(
                      child: Image(image: AssetImage(url1), width: 110,),
                      onTap: ()=>load_selected_url1(),
                  ),
                  SizedBox(width: 30,),
                  InkWell(
                    child: Image(image: AssetImage(url2), width: 110,),
                      onTap: ()=>load_selected_url2(),
                  ),
                ],
              ),
              SizedBox(
                height: 70,
              ),
              Text(
                message,
                style: TextStyle(color: Colors.red[300], fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 90,
              ),
              Expanded(
                child: Container(
                  color: Color(0xFFD2F0F7),
                  child: SizedBox(
                    width: 700,
                    height: 50,
                    child: FlatButton(
                      child: Text('다음', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                      onPressed: (){
                        if(gender==null){
                          setState(() {
                            message='먼저 성별을 선택해주세요!';
                          });
                        }else{
                          Firestore.instance
                              .collection('users')
                              .document(widget.user.uid)
                              .updateData ({
                            'gender' : gender,
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(widget.user)));
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void load_selected_url2(){
    if(url2==girl){
      if(url1!=boy_selected){
        setState(() {
          url2=girl_selected;
          gender='여성';
          message='';
        });
      }
    }else{
      setState(() {
        url2=girl;
        gender=null;
        message='';
      });
    }
  }

  void load_selected_url1(){
    if(url1==boy){
      if(url2!=girl_selected){
        setState(() {
          url1=boy_selected;
          gender='남성';
          message='';
        });
      }
    }else {
      setState(() {
        url1 = boy;
        gender=null;
        message='';
      });
    }
  }
}
