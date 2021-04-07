import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:memoryonmap/view/camer.dart';
import 'controller/dbhelper.dart';
import 'model/place.dart';
 
import 'dart:io';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await dbHelper.openMyDb();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final paidkey = "AIzaSyC3FEo_7bksnMhiBfGiZ9ruvW7c3bxRf2Y";
var c=0;
final distnitionindex=0;
  DBHelper dbHelper;
  GoogleMapController gmc;

  List<Place> places = [];

  List<Marker> marker = [];
  List<Polyline> polyline = [];
  List<LatLng> listoflatlng = [];
  PolylinePoints polylinePoints = PolylinePoints();
  var position = CameraPosition(target: LatLng(41.9028, 32.4964),zoom: 5);
  Future<Position> _getUserLocation() async {
    LocationPermission permission;
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("@@@@@@@@@@@@@@@location sevice is disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      /// this show ui to get user permission
      print("enter permission");
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    ///if no one of apove return current location
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  void addMarker(
      Position pos, String markerId, String markerTitle, Place place) async {
    final markers = Marker(
        onTap: () {
          showDialog(
              context: context,
              builder: (co) {
                return AlertDialog(
                  title: Text(place.name),
                  content: (place.image != '')
                      ? Image.file(File(place.image))
                      : Icon(Icons.hourglass_empty),
                );
              });
        },
        markerId: MarkerId(markerId),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(
            title: "${markerTitle} lat:${pos.latitude} long:${pos.longitude} "),
        icon: (markerId == 'currpos')
            ? BitmapDescriptor.defaultMarker
            : BitmapDescriptor.defaultMarkerWithHue(4));
    marker.add(markers);
    setState(() {
  
    });
  }

  Future getData() async {
    await dbHelper.openMyDb();
    places = await dbHelper.getPlace();
    setState(() {
      
    });

    places.forEach((element) {
      addMarker(
          Position(
            latitude: element.lat,
            longitude: element.lon,
          ),
          element.id.toString(),
          element.name,
          element);
      print(element.toMap());



      print(" marker length${marker.length}");
        
     

    });
  


  }

  void addPolyLine(String id, List<LatLng> l) {
    Polyline p =
        Polyline(polylineId: PolylineId(id), color: Colors.blue, points: l);

    polyline.add(p);
    setState(() {
      
    });
    print("#################");
    print(polyline[0].points);
  }

    getPolyineCoordinates(Position s, Place d) async {
    //final source = PointLatLng(6.5212402,3.3679965);
     final source = PointLatLng(s.latitude,s.longitude);

     //final destination = PointLatLng(30.0610207,31.3576671);
    final destination = PointLatLng(d.lat,d.lon);

    PolylineResult pResult = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyC3FEo_7bksnMhiBfGiZ9ruvW7c3bxRf2Y", source, destination,
        travelMode: TravelMode.walking,
        wayPoints: [PolylineWayPoint(location: "مستشفى بديات")]
        );
        print("hi");
    if(pResult.points.isNotEmpty){
       print("yes@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
   final pr=pResult.points;
       
      pr.forEach((v) { 
print("hi$v");

        listoflatlng.add(LatLng(v.latitude,v.longitude));


        print(listoflatlng[0]);
      });   
       
      addPolyLine("first", listoflatlng);
      print(polyline[0].polylineId);
    

    }


  }
  void onMapcreated(GoogleMapController controller) async{
    gmc=controller;
  }

  Future<void> inserData(Place place) async {
    await dbHelper.inserPlace(place);
    getData();
  }


  @override
  void initState() {
    dbHelper = DBHelper();

    // TODO: implement initS
    print(position.target.longitude);

    _getUserLocation().then((value) {
      print("welcome");
      position =
          CameraPosition(target: LatLng(value.latitude, value.longitude),zoom: 30);
          if(places.length!=0)
              getPolyineCoordinates(value, places[3]);
              print(places[0].lon);

     
      print(position.target.longitude);
      print(position.target.latitude);

      print("successfully");
    }).catchError((d) {
      print("error is: $d");
    });

    /////////sql

    getData();
    // inserData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("$c"),
        ),
        body: Stack(
                  children:[ 
                    
                    
                    
                    Container(
            child: GoogleMap(
              initialCameraPosition: position,
               myLocationEnabled: true,
          tiltGesturesEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
              markers: Set.of(marker),
              polylines: Set.of(polyline),
              onMapCreated: onMapcreated,
            ),
          ),]
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add_location,
            color: Colors.green,
          ),
          onPressed: () {
c++;
setState(() {
  
});
            //to update location each time i press add location
            _getUserLocation().then((value) {
              position = CameraPosition(
                  target: LatLng(value.latitude, value.longitude));

              print(position.target.longitude);
              print(position.target.latitude);

              print("successfully");
            }).catchError((d) {
              print("error is: $d");
            });



            showDialog(
                context: context,
                builder: (context) {
                  var place = Place(
                      lon: position.target.longitude,
                      lat: position.target.latitude,
                      name: "",
                      image: "");

                  return Alert(
                    insertData: inserData,
                    isNew: true,
                    place: place,
                  );
                });
          },
        ));
  }
}
///////////////////////alert
class Alert extends StatefulWidget {
   Function insertData;
  Place place;
  bool isNew;
  Alert({this.insertData, this.isNew, this.place });

  @override
  _AlertState createState() =>
      _AlertState(isNew: isNew, insertData: insertData, place: place);
}

class _AlertState extends State<Alert> {
  Function insertData;
  final name = TextEditingController();
  final lat = TextEditingController();
  final lon = TextEditingController();
  bool isNew = true;
  Place place;
  _AlertState({this.place, this.isNew, this.insertData});

  @override
  Widget build(BuildContext context) {
    lat.text = place.lat.toString();
    lon.text = place.lon.toString();
    return AlertDialog(
      title: Text("Place"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: InputDecoration(hintText: "name"),
            ),
            TextField(
              controller: lon,
              decoration: InputDecoration(hintText: "long"),
            ),
            TextField(
              controller: lat,
              decoration: InputDecoration(hintText: "lat"),
            ),
            IconButton(
                icon: Icon(Icons.camera_alt),
                onPressed: () {
                  place.lat = double.parse(lat.text);
                  place.lon = double.parse(lon.text);
                  place.name = name.text;

                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CameraScreen(place: place);
                  }));
                })
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("cancel")),
        ElevatedButton(
            onPressed: () {
              insertData(Place(
                  lon: double.parse(lon.text),
                  image: "",
                  lat: double.parse(lat.text),
                  name: name.text));
              Navigator.of(context).pop();
            },
            child: Text("Add"))
      ],
    );
  }
}
///  test////////
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:flutter_polyline_points/flutter_polyline_points.dart';

 

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Polyline example',
//       theme: ThemeData(
        
//         primarySwatch: Colors.orange,
//       ),
//       home: MapScreen(),
//     );
//   }
// }

// class MapScreen extends StatefulWidget {
//   @override
//   _MapScreenState createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController mapController;
//   double _originLatitude = 6.5212402, _originLongitude = 3.3679965;
//     double _destLatitude = 6.849660, _destLongitude = 3.648190;
//   // double _originLatitude = 26.48424, _originLongitude = 50.04551;
//   // double _destLatitude = 26.46423, _destLongitude = 50.06358;
//   Map<MarkerId, Marker> markers = {};
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   PolylinePoints polylinePoints = PolylinePoints();
 

//   @override
//   void initState() {
   

//     /// origin marker
//     _addMarker(LatLng(_originLatitude, _originLongitude), "origin",
//         BitmapDescriptor.defaultMarker);

//     /// destination marker
//     _addMarker(LatLng(_destLatitude, _destLongitude), "destination",
//         BitmapDescriptor.defaultMarkerWithHue(90));
//     _getPolyline();
//      super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//           body: GoogleMap(
//         initialCameraPosition: CameraPosition(
//             target: LatLng(_originLatitude, _originLongitude), zoom: 15),
//         // myLocationEnabled: true,
//         // tiltGesturesEnabled: true,
//         // compassEnabled: true,
//         // scrollGesturesEnabled: true,
//         // zoomGesturesEnabled: true,
       
//         markers: Set.of(markers.values),
//         polylines: Set.of(polylines.values),
//          //onMapCreated: _onMapCreated,
//       )),
//     );
//   }

//   void _onMapCreated(GoogleMapController controller) async {
//     mapController = controller;
//   }

//   _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
//     MarkerId markerId = MarkerId(id);
//     Marker marker =
//         Marker(markerId: markerId, icon: descriptor, position: position);
//     markers[markerId] = marker;
//   }

//   _addPolyLine() {
//     PolylineId id = PolylineId("poly");
//     Polyline polyline = Polyline(
//         polylineId: id, color: Colors.red, points: polylineCoordinates);
//     polylines[id] = polyline;
//     setState(() {});
//   }

//   _getPolyline() async {
//     PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
//         "AIzaSyC3FEo_7bksnMhiBfGiZ9ruvW7c3bxRf2Y",
//         PointLatLng(_originLatitude, _originLongitude),
//         PointLatLng(_destLatitude, _destLongitude),
//         travelMode: TravelMode.walking,
//         );
//     if (result.points.isNotEmpty) {
//       result.points.forEach((PointLatLng point) {
//         polylineCoordinates.add(LatLng(point.latitude, point.longitude));
//       });
//     }
//     _addPolyLine();
//   }
// }

