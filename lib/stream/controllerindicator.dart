import 'dart:async';

class ControllerStreamIndicator {
  final _controller=StreamController<String>.broadcast();
  StreamController<String> get controller =>_controller;
   Stream<String> get stream =>_controller.stream;
  

}