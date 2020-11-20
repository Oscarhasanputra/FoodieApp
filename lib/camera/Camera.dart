import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> camera;
  var indexCamera = 0;
  CameraScreen({@required this.camera});
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _controller;
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera[widget.indexCamera],
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    return Scaffold(
      body: FutureBuilder(
          future: _controller.initialize(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Stack(
                children: [
                  CameraPreview(_controller),
                  Positioned(
                    bottom: 50,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: Align(
                        alignment: Alignment.center,
                        child: IconButton(
                          onPressed: () async {
                            final pathString=path.join(
                              (await getTemporaryDirectory()).path,
                              DateTime.now().toString()+".png"
                            );

                            await _controller.takePicture(pathString);
                            Navigator.of(context).pop(pathString);
                            // Navigator.of(context).push(
                            //   MaterialPageRoute(
                            //     builder: (context){
                            //       return DisplayPictureScreen(imagePath: pathString,);    
                            //     }
                            //   )
                            // );
                          },
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 40,
                    left: 30,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.indexCamera = (widget.indexCamera + 1) % 2;
                          print(widget.indexCamera);
                        });
                      },
                      icon: Icon(
                        Icons.flip_camera_ios,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}