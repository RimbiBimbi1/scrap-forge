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
    if (angle % 360 == 0) return image;

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
        if (0 <= pixelVector[0] &&
            pixelVector[0] < w &&
            0 <= pixelVector[1] &&
            pixelVector[1] < h) {
          result.setPixel(x, y,
              image.getPixel(pixelVector[0].floor(), pixelVector[1].floor()));
        } else {
          result.setPixelRgb(x, y, 0, 0, 0);
        }
      }
    }
    return result;
  }

  static List<int> _getAxisDelimiters(imgLib.Image binImage) {
    int minX = binImage.width;
    int maxX = 0;
    int minY = binImage.height;
    int maxY = 0;

    for (int y = 0; y < binImage.height; y++) {
      for (int x = 0; x < binImage.width; x++) {
        if (binImage.getPixel(x, y).r == 255) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    return List.from([minX, minY, maxX, maxY]);
  }

  static double _getBoundaryCoverage(
      imgLib.Image binImage, List<int> delimiters, int errorMargin) {
    if (delimiters.length < 2) return 0;

    int imgW = binImage.width;
    int imgH = binImage.height;
    int boundaryW = (delimiters[2] - delimiters[0]);
    int boundaryH = (delimiters[3] - delimiters[1]);

    int boundaryLength = 2 * boundaryW + 2 * boundaryH;
    int coveredBoundaryPixels = 0;

    for (int x = delimiters[0]; x <= delimiters[2]; x++) {
      for (final int y in [delimiters[1], delimiters[3]]) {
        bool found = false;
        for (int e = -errorMargin; e <= errorMargin; e++) {
          try {
            if (binImage.getPixel(x, y + e).r == 255) {
              found = true;
            }
          } catch (e) {
            continue;
          }
        }
        if (found) coveredBoundaryPixels++;
      }
    }

    for (int y = delimiters[1]; y <= delimiters[3]; y++) {
      for (final int x in [delimiters[0], delimiters[2]]) {
        bool found = false;
        for (int e = -errorMargin; e <= errorMargin; e++) {
          try {
            if (binImage.getPixel(x + e, y).r == 255) {
              found = true;
            }
          } catch (e) {
            continue;
          }
        }
        if (found) coveredBoundaryPixels++;
      }
    }

    return math.min(coveredBoundaryPixels / boundaryLength, 1);
  }

  static imgLib.Image getBoundingAngle(imgLib.Image binImage) {
    // static int getBoundingAngle(imgLib.Image binImage) {
    double l = binImage.length.toDouble();
    int boundingAngle = 0;
    double maxScore = 0;

    imgLib.Image result = imgLib.Image.empty();
    //

    for (int angle = 0; angle < 90; angle++) {
      imgLib.Image rotated = rotate(binImage, angle);
      List<int> delimiters = _getAxisDelimiters(rotated);
      double boxToImageRatio = ((delimiters[2] - delimiters[0]) *
              (delimiters[3] - delimiters[1]).toDouble()) /
          l;
      double boundaryCoverage = _getBoundaryCoverage(rotated, delimiters, 1);
      // double score = coverage / field;
      double score =
          (boundaryCoverage * boxToImageRatio) + (1 - boxToImageRatio);
      // double score = (l / field);

      if (score > maxScore) {
        print(angle);
        print(score);
        print(boxToImageRatio);
        print(boundaryCoverage);
        maxScore = score;
        boundingAngle = angle;
        result = rotated;
      }
    }

    return result;
    // return boundingAngle;
  }
}
