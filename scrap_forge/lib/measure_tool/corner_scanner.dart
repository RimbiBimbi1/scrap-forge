import 'package:image/image.dart' as imgLib;

class CornerScanner {
  imgLib.Image image;

  CornerScanner(this.image);

  int xStart = 0;
  int yStart = 0;
  int xJump = 0;
  int yJump = 0;
  int yStep = 0;
  int xStep = 0;
  imgLib.Point fallback = imgLib.Point(0, 0);

  void configureCorner(int corner) {
    switch (corner) {
      case 0:
        {
          xStart = 0;
          yStart = 0;

          xJump = 1;
          yJump = 1;

          xStep = -1;
          yStep = 1;

          fallback = imgLib.Point(0, 0);
        }
      case 1:
        {
          xStart = image.width - 1;
          yStart = 0;

          xJump = 1;
          yJump = 1;

          xStep = -1;
          yStep = -1;

          fallback = imgLib.Point(image.width, 0);
        }
      case 2:
        {
          xStart = image.width - 1;
          yStart = image.height - 1;

          xJump = -1;
          yJump = -1;

          xStep = 1;
          yStep = -1;

          fallback = imgLib.Point(image.width, image.height);
        }
      default:
        {
          xStart = 0;
          yStart = image.height - 1;

          xJump = 1;
          yJump = -1;

          xStep = 1;
          yStep = 1;

          fallback = imgLib.Point(0, image.height);
        }
    }
  }

  imgLib.Point scanXPhase() {
    while ((0 <= xStart) && (xStart < image.width)) {
      int x = xStart;
      int y = yStart;

      while ((0 <= x) && (x < image.width) && (0 <= y) && (y < image.height)) {
        num pRed = image.getPixel(x, y).r;
        if (pRed == 0) {
          return imgLib.Point(x, y);
        }

        x += xStep;
        y += yStep;
      }
      xStart += xJump;
    }
    xStart -= xJump;
    yStart += yJump;
    return fallback;
  }

  imgLib.Point scanYPhase() {
    while ((0 <= yStart) && (yStart < image.height)) {
      int x = xStart;
      int y = yStart;

      while ((0 <= x) && (x < image.width) && (0 <= y) && (y < image.height)) {
        int pRed = image.getPixel(x, y).r.toInt();
        if (pRed == 0) {
          return imgLib.Point(x, y);
        }

        x += xStep;
        y += yStep;
      }
      yStart += yJump;
    }
    xStart += xJump;
    yStart -= yJump;
    return fallback;
  }

  imgLib.Point scanForCorner(int corner) {
    configureCorner(corner);

    imgLib.Point point = fallback;
    if (corner % 2 == 0) {
      point = scanXPhase();
      if (point.x == fallback.x && point.y == fallback.y) {
        point == scanYPhase();
      }
    } else {
      point = scanYPhase();
      if (point.x == fallback.x && point.y == fallback.y) {
        point == scanXPhase();
      }
    }
    return point;
  }

  List<imgLib.Point> scanForCorners() {
    return List.from([
      scanForCorner(0),
      scanForCorner(1),
      scanForCorner(2),
      scanForCorner(3),
    ]);
  }
}
