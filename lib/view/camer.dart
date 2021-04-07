import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:memoryonmap/view/picturescreen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:memoryonmap/model/place.dart';
import 'package:path/path.dart';
class CameraScreen extends StatefulWidget {
  Place place;
CameraScreen({this.place});
  @override
  _CameraScreenState createState() => _CameraScreenState(place: this.place);
}

class _CameraScreenState extends State<CameraScreen> {
    Place place;

CameraController _controller;

List<CameraDescription> cameras;
CameraDescription camera;
Widget cameraPreview;
Image image;
_CameraScreenState({this.place});
//set 
Future setCamera() async {
 cameras = await availableCameras();
 if (cameras.length != 0) {
 camera = cameras.first;
 }
 }
@override
void initState() {
  setCamera().then((value) {
_controller=CameraController(camera, ResolutionPreset.low);
_controller.initialize().then((value){
///camcontroller estaplish con between device's camera
//camera describtion define type of camera front or back camera
cameraPreview=Center(child:CameraPreview(_controller));
setState(() {
  cameraPreview=cameraPreview;
});
});


  });
    super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("camera"),actions: [IconButton(icon: Icon(Icons.check), onPressed:()async{

//store picture in temp dir after taking it
         final path=join((await getTemporaryDirectory()).path,'${DateTime.now()}.png');
         await _controller.takePicture(path);
         ///
         ///after take pic showit in picscreen and save place with picture;
         Navigator.push(context, MaterialPageRoute(builder: (context){

return PictureScreen(place:place,path:path);
         }));




      })],),
      body:cameraPreview,
      
    );
  }
}