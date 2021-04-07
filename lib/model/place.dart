class Place{
int id;
 String name;
 double lat;
 double lon;
 String image;

Place({this.image,this.lon,this.name,this.id,this.lat});


 Map<String,dynamic> toMap(){
return {"id":id==0?null:id,"name":name,"lat":lat,"lon":lon,"image":image};


 }


}