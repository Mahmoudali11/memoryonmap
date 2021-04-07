//this screen show pic and save it in db
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memoryonmap/main.dart';
import 'package:memoryonmap/model/place.dart';
import 'package:memoryonmap/controller/dbhelper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PictureScreen extends StatelessWidget {
  Place place;
  String path;
  DBHelper db=DBHelper();
  PictureScreen({this.place, this.path});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                place.image = path;
                print("hiiiiiiiiiiiiii"+place.lat.toString());
                 
                await db.inserPlace(place).then((value) =>
                    Fluttertoast.showToast(
                        msg: "data save successfully",
                        textColor: Colors.white,
                        backgroundColor: Colors.black,
                        gravity: ToastGravity.BOTTOM));
                        Navigator.push(context,MaterialPageRoute(builder: (context){
                         return MyHomePage();

                        }));
              })
        ],
      ),
      body: Container(
        child: Image.file(File(path)),
      ),
    );
  }
}
