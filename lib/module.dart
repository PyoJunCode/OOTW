import 'package:cloud_firestore/cloud_firestore.dart';

class Record {
  final String name;
  final String url;
  final String img;
  final String documentId;
  final String price;

  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['link'] != null),
        assert(map['img'] != null),
        assert(map['docID'] != null),


        name = map['name'],
        url = map['link'],
        img = map['img'],
        documentId = map['docID'],
        price = map['price'];




  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

}

