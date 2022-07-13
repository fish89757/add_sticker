import 'dart:io';

import 'package:add_sticker/bean/record_image_sticker_bean.dart';
import 'package:add_sticker/bean/record_sticker_bean.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

import '../base_controller.dart';

//添加贴纸控件
class AddStickerWidget extends StatefulWidget {
  final AddStickerController? controller;
  final ImageStickerBean imageStickerBean;

  const AddStickerWidget(
      {Key? key,
      this.controller,
      required this.imageStickerBean})
      : super(key: key);

  @override
  _AddStickerWidgetState createState() => _AddStickerWidgetState();
}

class _AddStickerWidgetState extends State<AddStickerWidget> {
  //截屏的key
  GlobalKey screenShotGlobalKey = GlobalKey();

  //图片尺寸key
  GlobalKey imageSizeKey = GlobalKey();

  //贴纸数据列表
  List<StickerBean>? stickerList;

  //贴纸控件列表
  late List<Widget> stickerWidgetList;


  late ImageStickerBean imageStickerBean;

  //用来计算右下角图标的手势
  late Vector2 lastVector2;

  @override
  void initState() {
    super.initState();
    imageStickerBean = widget.imageStickerBean;
    stickerList = imageStickerBean.stickerList;
    stickerWidgetList = [];
  }

  initCoverView() {
    //如果width等为空，说明是第一张添加，需要获取到当前图片的宽高及位置信息，用来设置贴纸可移动的范围
    if (imageStickerBean.width == null || imageStickerBean.height == null) {
      //获取宽高
      imageStickerBean.width = imageSizeKey.currentContext!.size!.width;
      imageStickerBean.height = imageSizeKey.currentContext!.size!.height;
      RenderBox box =
          imageSizeKey.currentContext!.findRenderObject() as RenderBox;
      //根据图片的宽高和位置计算顶部和顶部遮挡视图的高度
      imageStickerBean.topCoverHeight = box.localToGlobal(Offset.zero).dy;
      imageStickerBean.bottomCoverHeight = MediaQuery.of(context).size.height -
          box.localToGlobal(Offset.zero).dy -
          imageStickerBean.height!;
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller?.bindState(this);
  }

  @override
  void dispose() {
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    refreshListWidget();
    return Scaffold(
      backgroundColor: Color(0xff000000),
      body: GestureDetector(
        onTap: () {
          unSelectAll();
          widget.controller?.onStickerAllUnSelect?.call(false);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(
                key: screenShotGlobalKey,
                child: Container(
                  width: imageStickerBean.width,
                  height: imageStickerBean.height,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(imageStickerBean.imagePath,fit: BoxFit.fill,key: imageSizeKey,),
                      Stack(
                        alignment: Alignment.center,
                        children: stickerWidgetList,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                child: Container(
                  height: imageStickerBean.topCoverHeight,
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xff000000),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  height: imageStickerBean.bottomCoverHeight,
                  width: MediaQuery.of(context).size.width,
                  color: Color(0xff000000),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //刷新列表数据
  refreshListWidget() {
    stickerWidgetList.clear();
    if (stickerList != null) {
      for (StickerBean bean in stickerList!) {
        stickerWidgetList.add(getSingleStickerWidget(bean));
      }
    }
  }

  //取消所有贴纸的选中状态
  unSelectAll() {
    if (stickerList == null || stickerList!.length == 0) {
      return;
    }
    for (StickerBean bean in stickerList!) {
      bean.isSelected = false;
    }
    widget.controller?.onStickerAllUnSelect?.call(false);
    setState(() {});
  }

  //选中一个贴纸
  selectSticker(StickerBean bean) {
    for (StickerBean stickerBean in stickerList!) {
      stickerBean.isSelected = bean.id == stickerBean.id;
      //更新最后操作时间戳
      if (stickerBean.isSelected) {
        stickerBean.time = DateTime.now().millisecondsSinceEpoch;
      }
    }
    //重新排序，将当前点击的排到数组最后（stack最上面）
    stickerList!.sort();
    widget.controller?.onStickerAllUnSelect?.call(true);
    setState(() {});
  }

  //添加贴纸
  addSticker(String path, String name) {
    initCoverView();
    // //取消所有贴纸的选中状态，选中新增的贴纸
    unSelectAll();
    //新建一张贴纸数据，并将贴纸的初始化位置设置在图片的中心,因为同一张贴纸可以多次添加，删除时要根据id删除，
    //这里id取当前时间毫秒值（唯一）
    stickerList!.add(StickerBean.newSticker(
        offset: Offset(
            imageStickerBean.width! / 2 -
                imageStickerBean.stickerDecorationWidth / 2,
            imageStickerBean.height! / 2 -
                imageStickerBean.stickerDecorationHeight / 2),
        imagePath: path,
        id: "${DateTime.now().millisecondsSinceEpoch}",
        stickerName: name));
    setState(() {});
    widget.controller?.onStickerAllUnSelect?.call(true);
  }

  //删除贴纸
  deleteSticker(String id) {
    stickerList!.removeWhere((element) => id == element.id);
    setState(() {});
  }

  //单张贴纸视图
  Widget getSingleStickerWidget(StickerBean stickerBean) {
    //单张贴纸控件
    return Positioned(
      left: stickerBean.positionOffset.dx,
      top: stickerBean.positionOffset.dy,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateZ(stickerBean.rotate),
        child: Container(
          width: imageStickerBean.stickerDecorationWidth * stickerBean.scale +
              imageStickerBean.iconSize,
          height: imageStickerBean.stickerDecorationHeight * stickerBean.scale +
              imageStickerBean.iconSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height:
                    imageStickerBean.stickerDecorationWidth * stickerBean.scale,
                width: imageStickerBean.stickerDecorationHeight *
                    stickerBean.scale,
                decoration: stickerBean.isSelected
                    ? BoxDecoration(
                        border: Border.all(
                            color: const Color(0xfff9f9f9), width: 1))
                    : null,
                child: onlyStickerView(stickerBean),
              ),
              stickerBean.isSelected
                  ? Positioned(
                      top: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: () {
                          deleteSticker(stickerBean.id);
                        },
                        child: Container(
                          width: imageStickerBean.iconSize,
                          height: imageStickerBean.iconSize,
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/delete_sticker.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ))
                  : SizedBox(),
              stickerBean.isSelected
                  ? Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onPanStart: (d) {
                          //记录触摸点向量（向量计算的原点坐标为绝对位置原点坐标（0,0），因为图片是相对自己旋转和缩放，所以这里要把向量计算的
                          // 原点坐标转化为图片中心点坐标）
                          lastVector2 = Vector2(
                                  d.globalPosition.dx, d.globalPosition.dy) -
                              getImageCenterVector(stickerBean);
                        },
                        onPanUpdate: (d) {
                          //当前位置向量
                          Vector2 currentVector2 = Vector2(
                                  d.globalPosition.dx, d.globalPosition.dy) -
                              getImageCenterVector(stickerBean);
                          //计算两个向量之间的角度,然后计算图片旋转角度
                          double angle =
                              currentVector2.angleToSigned(lastVector2);
                          stickerBean.rotate = stickerBean.lastRotate - angle;
                          //计算两个点相对原点坐标的距离,距离的比例即为缩放比例
                          double distance1 =
                              Vector2(0, 0).distanceTo(lastVector2);
                          double distance2 =
                              Vector2(0, 0).distanceTo(currentVector2);
                          //图片缩放比例计算
                          stickerBean.scale =
                              stickerBean.lastScale * distance2 / distance1;
                          setState(() {});
                          lastVector2 = currentVector2;
                          //记录缩放和旋转
                          stickerBean.lastRotate = stickerBean.rotate;
                          stickerBean.lastScale = stickerBean.scale;
                        },
                        child: Container(
                          width: imageStickerBean.iconSize,
                          height: imageStickerBean.iconSize,
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/images/modify_sticker.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ))
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  //获取图片中心坐标，作为向量计算的原点坐标
  getImageCenterVector(StickerBean stickerBean) {
    //图片中心点坐标为：
    //x:当前贴纸x坐标+删除按钮尺寸/2+贴纸操作框宽度/2
    //y:背景图片距离手机顶部的距离+当前贴纸y坐标+删除按钮尺寸/2+贴纸操作框高度/2
    return Vector2(
        (stickerBean.positionOffset.dx +
            imageStickerBean.iconSize / 2 +
            imageStickerBean.stickerDecorationWidth / 2),
        (imageStickerBean.topCoverHeight +
            stickerBean.positionOffset.dy +
            imageStickerBean.iconSize / 2 +
            imageStickerBean.stickerDecorationHeight / 2));
  }

  onlyStickerView(StickerBean stickerBean) {
    return Stack(
      children: [
        Transform(
          transform: Matrix4.identity()..scale(stickerBean.scale),
          alignment: Alignment.center,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              selectSticker(stickerBean);
            },
            onScaleStart: (d) {
              selectSticker(stickerBean);
              //记录触摸点
              stickerBean.lastOffset = d.focalPoint;
            },
            onScaleUpdate: (d) {
              //因为在手势开始时进行了重新排序，所以要重置stickerBean的指向
              if (!stickerBean.isSelected) {
                stickerBean =
                    stickerList!.singleWhere((element) => element.isSelected);
              }
              // if(!stickerBean.isSelected){
              //   selectSticker(stickerBean);
              // }
              //计算位置信息
              stickerBean.positionOffset = stickerBean.positionOffset +
                  d.focalPoint -
                  stickerBean.lastOffset;
              //计算缩放比例
              stickerBean.scale = stickerBean.lastScale * d.scale;
              //计算旋转角度
              stickerBean.rotate = stickerBean.lastRotate + d.rotation;
              setState(() {});
              //重置最后的触摸点
              stickerBean.lastOffset = d.focalPoint;
            },
            onScaleEnd: (d) {
              //记录手势结束时的缩放比例和旋转角度，用来进行下一次缩放操作
              stickerBean.lastScale = stickerBean.scale;
              stickerBean.lastRotate = stickerBean.rotate;
            },
            child: Center(
              child: Image.asset(
                stickerBean.imagePath,
                width: imageStickerBean.stickerWidth,
                height: imageStickerBean.stickerHeight,
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddStickerController extends BaseController<_AddStickerWidgetState> {
  Function(bool isSelectStatus)? onStickerAllUnSelect;

  addStickerStatusListener(
      {Function(bool isSelectStatus)? onStickerAllUnSelectListener}) {
    onStickerAllUnSelect = onStickerAllUnSelectListener;
  }

  //添加贴纸
  addSticker(String path, String name) {
    state?.addSticker(path, name);
  }

  //获取已经添加的贴纸数量
  int getStickerNum() {
    return state?.stickerList?.length ?? 0;
  }
}
