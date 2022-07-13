import 'dart:ui';

class StickerBean extends Comparable<StickerBean>{
  //上次结束拖动时的偏移量
  late Offset lastOffset;

  //当前偏移量
  late Offset positionOffset;

  //当前缩放比例
  late double scale;

  //上一次结束缩放时的比例
  late double lastScale;

  //当前旋转角度
  late double rotate;

  //上一次结束旋转时的角度
  late double lastRotate;

  //是否被选中
  late bool isSelected;

  //图片路径
  late String imagePath;

  //唯一id
  late String id;

  //用户最后操作的时间戳
  late int time;

  late String stickerName;
  StickerBean.newSticker(
      {required Offset offset, required String imagePath, required id,required stickerName}) {
    positionOffset = offset;
    lastOffset = Offset.zero;
    scale = 1.0;
    lastScale = 1.0;
    rotate = 0;
    lastRotate = 0;
    isSelected = true;
    this.imagePath = imagePath;
    this.id = id;
    time=DateTime.now().millisecondsSinceEpoch;
    this.stickerName=stickerName;
  }

  @override
  int compareTo(StickerBean other) {
    //重写比较方法，最近操作的贴纸在列表的最后（stack的最顶部）
    return time.compareTo(other.time);
    // return other.time.compareTo(time);
  }
}
