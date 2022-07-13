import 'package:add_sticker/image_util.dart';
import 'package:add_sticker/show_image_result_page.dart';
import 'package:add_sticker/widget/add_sticker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'bean/record_image_sticker_bean.dart';

class AddStickerPage extends StatefulWidget {
  const AddStickerPage({Key? key}) : super(key: key);

  @override
  _AddStickerPageState createState() => _AddStickerPageState();
}

class _AddStickerPageState extends State<AddStickerPage> {
  late AddStickerController controller;
  late ImageStickerBean  imageStickerBean;
  @override
  void initState() {
    super.initState();
    imageStickerBean= ImageStickerBean("assets/images/image2.webp");
   controller= AddStickerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AddStickerWidget(imageStickerBean: imageStickerBean,controller: controller,),
          Positioned(
            left: 100,
            top: 150,
            child: GestureDetector(
              onTap: (){
                controller.addSticker("assets/images/sticker.png", "sticker");
              },
              child: Container(width: 100,height: 50,child: Center(
                child: Text("添加贴纸"),
              ),color: Colors.white,),
            ),
          ),
          Positioned(
            right: 100,
            top: 150,
            child: GestureDetector(
              onTap: (){
                ImageUtil.imageStickerSynthesis(imageStickerBean).then((value){
                  Navigator.push(context, CupertinoPageRoute(builder: (context){
                    return ShowImageResultPage(filePath: value!);
                  }));
                });
              },
              child: Container(width: 100,height: 50,child: Center(
                child: Text("合成图片"),
              ),color: Colors.white,),
            ),
          )
        ],
      ),
    );
  }
}
