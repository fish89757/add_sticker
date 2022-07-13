import 'package:flutter/material.dart';

///要实现controller，可以集成此类
class BaseController<T extends State>{
  T? state;
  bindState(T bindState){
    state=bindState;
  }

  dispose(){
    state=null;
  }
}