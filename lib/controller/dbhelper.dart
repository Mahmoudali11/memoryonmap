import 'package:memoryonmap/model/place.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DBHelper{


  
int version=1;
Database db;
static final dbh=DBHelper._internal();
DBHelper._internal();
factory DBHelper(){

return dbh;

}

Future<Database>openMyDb() async {
  if(db==null){

  final dbpath= await getDatabasesPath();
  final path=join(dbpath,'memoryonmap.db');
       db=await openDatabase( path,version: version,onCreate: (data,version){
   data.execute('create table place(id integer primary key,name text,lon double,lat double,image text)');   

       });
  }
 return db;

}

Future<int>inserPlace(Place itm)async{
int id=await db.insert('place', itm.toMap(),conflictAlgorithm: ConflictAlgorithm.replace);
return id;


}
Future <List<Place>> getPlace() async{

  List ls=await db.query('place');
       List<Place> lm=ls.map((i){
      return Place(id: i["id"],name:i["name"],lon: i["lon"],lat: i["lat"],image: i["image"]);


       }).toList();
       

return lm;
  

  




}





}