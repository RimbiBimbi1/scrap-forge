import 'package:image/image.dart' as imgLib;
import 'ImageProcessor.dart' as iP;
import 'dart:math' as math;

class AutoBoundingBoxScanner {
  imgLib.Image original;
  imgLib.Image expanded = imgLib.Image(width: 0, height: 0);

  AutoBoundingBoxScanner({required this.original});

  static imgLib.Image getExpandedToDiagonals(imgLib.Image image) {
    int w = image.width;
    int h = image.height;
    int diagonal = math.sqrt(w * w + h * h).round();
    int horizontalMargin = ((diagonal - w) / 2).round();
    int verticalMargin = ((diagonal - h) / 2).round();

    imgLib.Image result = imgLib.Image(width: diagonal, height: diagonal);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        result.setPixel(
            x + horizontalMargin, y + verticalMargin, image.getPixel(x, y));
      }
    }

    return result;
  }

  void expandToDiagonals() => expanded = getExpandedToDiagonals(original);

  static List<double> matrixXVector(List<List<double>> a, List<double> b) {
    List<double> result = [0, 0, 0];

    for (int yi = 0; yi < 3; yi++) {
      double n = 0;
      for (int k = 0; k < 3; k++) {
        n += a[yi][k] * b[k];
      }
      result[yi] = n;
    }
    return result;
  }

  static List<List<double>> matrixXMatrix(
      List<List<double>> a, List<List<double>> b) {
    List<List<double>> result = [
      [0, 0, 0],
      [0, 0, 0],
      [0, 0, 0]
    ];
    for (int yi = 0; yi < 3; yi++) {
      for (int xj = 0; xj < 3; xj++) {
        double n = 0;
        for (int k = 0; k < 3; k++) {
          n += a[yi][k] * b[k][xj];
        }
        result[yi][xj] = n;
      }
    }
    return result;
  }

  static imgLib.Image rotate(imgLib.Image image, int angle) {
    imgLib.Image result =
        imgLib.Image(width: image.width, height: image.height);
    int w = image.width;
    int h = image.height;
    double xOffset = (w / 2);
    double yOffset = (h / 2);
    double sin = math.sin(math.pi * angle / 180);
    double cos = math.cos(math.pi * angle / 180);

    List<List<double>> translationMatrix1 = [
      [1, 0, -xOffset],
      [0, 1, -yOffset],
      [0, 0, 1]
    ];

    List<List<double>> rotationMatrix = [
      [cos, -sin, 0],
      [sin, cos, 0],
      [0, 0, 1]
    ];

    List<List<double>> translationMatrix2 = [
      [1, 0, xOffset],
      [0, 1, yOffset],
      [0, 0, 1]
    ];

    List<List<double>> resultMatrix = matrixXMatrix(
        translationMatrix2, matrixXMatrix(rotationMatrix, translationMatrix1));

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        List<double> pixelVector =
            matrixXVector(resultMatrix, [x.toDouble(), y.toDouble(), 1]);
        try {
          result.setPixel(x, y,
              image.getPixel(pixelVector[0].round(), pixelVector[1].round()));
        } catch (e) {
          result.setPixelRgb(x, y, 0, 0, 0);
        }
      }
    }
    return result;
  }
}
