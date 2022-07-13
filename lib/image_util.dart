import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'bean/record_image_sticker_bean.dart';
import 'dart:ui' as ui;

import 'bean/record_sticker_bean.dart';

class ImageUtil{
  //图片贴纸合成
  //[bean] 贴纸数据
  //return 合成后的图片路径
  static Future<String?> imageStickerSynthesis(ImageStickerBean bean) async {
    //如果没有添加贴纸，则直接返回原图路径
    if (bean.stickerList.isEmpty) {
     return bean.imagePath;
    }
    var pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
    Paint paint = Paint();
    //=======开始绘制底部图片==========
    ui.Image backImage = await loadAssetImage(bean.imagePath);
    Rect backSrc = Rect.fromLTWH(
        0, 0, backImage.width.toDouble(), backImage.height.toDouble());
    Rect backDst = Rect.fromLTWH(
        0, 0, backImage.width.toDouble(), backImage.height.toDouble());
    canvas.drawImageRect(backImage, backSrc, backDst, paint);
    //=======绘制底部图片结束==========
    //=======开始绘制贴纸=======
    //计算出图片的真实宽高与计算宽高的比例（绘制是通过真实宽高计算缩放和偏移）
    double imageScale = backImage.width.toDouble() / bean.width!;
    //循环绘制出所有贴纸
    for (StickerBean stickerBean in bean.stickerList) {
      canvas.save();
      ui.Image stickerImage = await loadAssetImage(stickerBean.imagePath);
      //计算出当前贴纸的中心坐标
      double centerDx = (stickerBean.positionOffset.dx +
          (bean.iconSize +
              bean.stickerDecorationWidth * stickerBean.scale) /
              2) *
          imageScale;
      double centerDy = (stickerBean.positionOffset.dy +
          (bean.iconSize +
              bean.stickerDecorationHeight * stickerBean.scale) /
              2) *
          imageScale;
      //将画布的中心移动到贴纸的中心
      canvas.translate(centerDx, centerDy);
      //旋转画布，角度为贴纸旋转的角度
      canvas.rotate(stickerBean.rotate);
      //计算绘制贴纸的坐标（贴纸左上角）
      double stickerDx =
          -bean.stickerWidth * stickerBean.scale * imageScale / 2;
      double stickerDy =
          -bean.stickerHeight * stickerBean.scale * imageScale / 2;
      Rect src = Rect.fromLTWH(
          0, 0, stickerImage.width.toDouble(), stickerImage.height.toDouble());
      //绘制图片rect
      Rect dst = Rect.fromLTWH(
          stickerDx,
          stickerDy,
          bean.stickerWidth * stickerBean.scale * imageScale,
          bean.stickerHeight * stickerBean.scale * imageScale);
      //绘制贴纸
      canvas.drawImageRect(stickerImage, src, dst, paint);
      //保存此次绘制图层并重置画布
      canvas.restore();
    }
    //将绘制内容转为Uint8List数据
    ui.Image showImage = await pictureRecorder
        .endRecording()
        .toImage(backImage.width, backImage.height);
    ByteData? pngImageBytes =
    await showImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = pngImageBytes!.buffer.asUint8List();
    //将Uint8List数据写入文件
    bean.filePath = await writeToFile(pngBytes);
    return bean.filePath;
  }

  //将Uint8List写入file
  static Future<String> writeToFile(Uint8List bytes) async {
    Directory directory = await getTemporaryDirectory();
    String path = directory.path +
        "/cece_sticker_${DateTime.now().millisecondsSinceEpoch}.png";
    File(path).writeAsBytes(bytes);
    return path;
  }

  //加载资源图片到内存中
  static Future<ui.Image> loadAssetImage(String path) async {
    // 加载资源文件
    final data = await rootBundle.load(path);
    // 把资源文件转换成Uint8List类型
    final bytes = data.buffer.asUint8List();
    // 解析Uint8List类型的数据图片
    final image = await decodeImageFromList(bytes);
    return image;
  }

  //加载file图片到内存中
  static Future<ui.Image> loadFileImage(File file) async {
    // 通过字节的方式读取本地文件
    final bytes = await file.readAsBytes();
    // 解析图片资源
    final image = await decodeImageFromList(bytes);
    return image;
  }
}