import 'package:image/image.dart' as imgLib;
import 'dart:math' as math;

class TriangleTexturer {
  imgLib.Image textureImg;
  imgLib.Image canvasImg;

  List<imgLib.Point> from;
  List<imgLib.Point> to;

  TriangleTexturer(this.textureImg, this.canvasImg, this.from, this.to);

  void setTriangles(List<imgLib.Point> from, List<imgLib.Point> to) {
    this.from = from;
    this.to = to;
  }

  imgLib.Image getResult() {
    return canvasImg;
  }

  void texture() {
    num det = ((to[1].x - to[0].x) * (to[2].y - to[0].y)) -
        ((to[1].y - to[0].y) * (to[2].x - to[0].x));

    for (int y = 0; y < canvasImg.height; y++) {
      for (int x = 0; x < canvasImg.width; x++) {
        num v = ((x - to[0].x) * (to[2].y - to[0].y) -
                (y - to[0].y) * (to[2].x - to[0].x)) /
            det;

        num w = ((y - to[0].y) * (to[1].x - to[0].x) -
                (x - to[0].x) * (to[1].y - to[0].y)) /
            det;

        num u = 1.0 - v - w;

        if (0 <= u && 1 >= u && 0 <= v && 1 >= v && 0 <= w && 1 >= w) {
          num a = u * from[0].x + v * from[1].x + w * from[2].x;
          num b = u * from[0].y + v * from[1].y + w * from[2].y;
          num xT = a.floor();

          num yT = b.floor();

          a = a - xT;
          b = b - yT;

          if (xT > 0 &&
              xT < textureImg.width &&
              yT > 0 &&
              yT < textureImg.height) {
            canvasImg.setPixel(
                x, y, textureImg.getPixel(xT.toInt(), yT.toInt()));
          }
        }
      }
    }
  }
}
