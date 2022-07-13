
import 'package:add_sticker/bean/record_sticker_bean.dart';

class ImageStickerBean {
  //顶部遮挡高度
  late double topCoverHeight;

  //底部遮挡高度
  late double bottomCoverHeight;

  //贴纸数据集合
  late List<StickerBean> stickerList;

  //当前图片的宽度
  double? width;

  //当前图片的高度
  double? height;

  //图片信息
  late String imagePath;

  //贴纸的初始宽度
  late double stickerWidth;

  //贴纸的初始高度
  late double stickerHeight;

  //贴纸操作框的初始宽度
  late double stickerDecorationWidth;

  //贴纸操作框的初始高度
  late double stickerDecorationHeight;

  //贴纸操作框删除按钮和缩放按钮的尺寸
  late double iconSize;

  //贴纸和图片合成之后图片的存储路径
  String? filePath;

  ImageStickerBean(this.imagePath) {
    topCoverHeight = 0;
    bottomCoverHeight = 0;
    stickerList = [];
    stickerWidth = 116;
    stickerHeight = 116;
    stickerDecorationWidth = 116;
    stickerDecorationHeight = 116;
    iconSize = 32;
  }


  static ImageStickerBean copy(ImageStickerBean bean) {
    ImageStickerBean imageStickerBean =
        ImageStickerBean(bean.imagePath);
    imageStickerBean.topCoverHeight = bean.topCoverHeight;
    imageStickerBean.bottomCoverHeight = bean.bottomCoverHeight;
    imageStickerBean.stickerList = List.from(bean.stickerList);
    imageStickerBean.width = bean.width;
    imageStickerBean.height = bean.height;
    imageStickerBean.stickerWidth = bean.stickerWidth;
    imageStickerBean.stickerHeight = bean.stickerHeight;
    imageStickerBean.stickerDecorationWidth = bean.stickerDecorationWidth;
    imageStickerBean.stickerDecorationHeight = bean.stickerDecorationHeight;
    imageStickerBean.iconSize = bean.iconSize;
    imageStickerBean.filePath = bean.filePath;

    return imageStickerBean;
  }
}
