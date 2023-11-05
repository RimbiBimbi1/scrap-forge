import 'dart:html';

import 'package:image/image.dart' as imgLib;
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

  static List<List<double>> calculateCenterRotationMatrix(
      imgLib.Image image, double angle) {
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

    return matrixXMatrix(
        translationMatrix2, matrixXMatrix(rotationMatrix, translationMatrix1));
  }

  static List<imgLib.Point> rotatePixels(
      imgLib.Image image, List<imgLib.Point> points, double angle) {
    if (angle % 360 == 0) return points;

    List<imgLib.Point> result = List.filled(points.length, imgLib.Point(0, 0));

    List<List<double>> rotationMatrix =
        calculateCenterRotationMatrix(image, angle);

    for (int i = 0; i < points.length; i++) {
      List<double> pixelVector = matrixXVector(
          rotationMatrix, [points[i].x.toDouble(), points[i].y.toDouble(), 1]);
      result[i] = imgLib.Point(pixelVector[0], pixelVector[1]);
    }

    return result;
  }

  static imgLib.Image rotate(imgLib.Image image, double angle) {
    if (angle % 360 == 0) return image;

    imgLib.Image result =
        imgLib.Image(width: image.width, height: image.height);
    int w = image.width;
    int h = image.height;

    List<List<double>> rotationMatrix =
        calculateCenterRotationMatrix(image, angle);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        List<double> pixelVector =
            matrixXVector(rotationMatrix, [x.toDouble(), y.toDouble(), 1]);
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

  static imgLib.Image rotateBin(imgLib.Image binImage, double angle) {
    if (angle % 360 == 0) return binImage;

    imgLib.Image result =
        imgLib.Image(width: binImage.width, height: binImage.height);
    int w = binImage.width;
    int h = binImage.height;

    List<List<double>> rotationMatrix =
        calculateCenterRotationMatrix(binImage, angle);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (0 < binImage.getPixel(x, y).r) {
          List<double> pixelVector =
              matrixXVector(rotationMatrix, [x.toDouble(), y.toDouble(), 1]);
          if (0 <= pixelVector[0] &&
              pixelVector[0] < w &&
              0 <= pixelVector[1] &&
              pixelVector[1] < h) {
            result.setPixel(pixelVector[0].floor(), pixelVector[1].floor(),
                binImage.getPixel(x, y));
          }
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
        if (50 < binImage.getPixel(x, y).r) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }

    return List.from([minX, minY, maxX, maxY]);
  }

  // static double _getBoundaryCoverage(
  //     imgLib.Image binImage, List<int> delimiters, int errorMargin) {
  //   if (delimiters.length < 2) return 0;

  //   int imgW = binImage.width;
  //   int imgH = binImage.height;
  //   int boundaryW = (delimiters[2] - delimiters[0]);
  //   int boundaryH = (delimiters[3] - delimiters[1]);

  //   int boundaryLength = 2 * boundaryW + 2 * boundaryH;
  //   int coveredBoundaryPixels = 0;

  //   for (int x = delimiters[0]; x <= delimiters[2]; x++) {
  //     for (final int y in [delimiters[1], delimiters[3]]) {
  //       bool found = false;
  //       for (int e = -errorMargin; e <= errorMargin; e++) {
  //         try {
  //           if (binImage.getPixel(x, y + e).r == 255) {
  //             found = true;
  //           }
  //         } catch (e) {
  //           continue;
  //         }
  //       }
  //       if (found) coveredBoundaryPixels++;
  //     }
  //   }

  //   for (int y = delimiters[1]; y <= delimiters[3]; y++) {
  //     for (final int x in [delimiters[0], delimiters[2]]) {
  //       bool found = false;
  //       for (int e = -errorMargin; e <= errorMargin; e++) {
  //         try {
  //           if (binImage.getPixel(x + e, y).r == 255) {
  //             found = true;
  //           }
  //         } catch (e) {
  //           continue;
  //         }
  //       }
  //       if (found) coveredBoundaryPixels++;
  //     }
  //   }

  //   return math.min(coveredBoundaryPixels / boundaryLength, 1);
  // }

  static int _getBoundaryCoverage(
      imgLib.Image binImage, List<int> delimiters, int errorMargin) {
    if (delimiters.length < 4) return 0;

    int boundaryW = (delimiters[2] - delimiters[0]);
    int boundaryH = (delimiters[3] - delimiters[1]);

    int boundaryLength = 2 * boundaryW + 2 * boundaryH;
    int coveredBoundaryPixels = 0;

    for (final int y in [delimiters[1], delimiters[3]]) {
      int left = -1;
      int right = -1;

      for (int x = delimiters[0]; x <= delimiters[2]; x++) {
        bool found = false;

        for (int e = -errorMargin; e <= errorMargin; e++) {
          try {
            if (50 < binImage.getPixel(x, y + e).r) {
              found = true;
            }
          } catch (e) {
            continue;
          }
        }
        if (found) {
          if (left == -1) {
            left = x;
          }
          right = x + 1;
        }
      }

      coveredBoundaryPixels += (right - left).abs();
    }

    for (final int x in [delimiters[0], delimiters[2]]) {
      int top = -1;
      int bottom = -1;

      for (int y = delimiters[1]; y <= delimiters[3]; y++) {
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
        if (found) {
          if (top == -1) {
            top = x;
          }
          bottom = x + 1;
        }
      }
      coveredBoundaryPixels += (bottom - top).abs();
    }

    // return math.min(coveredBoundaryPixels / boundaryLength, 1);
    return coveredBoundaryPixels;
  }

  static imgLib.Image getBoundingAngle(imgLib.Image binImage) {
    // static double getBoundingBoxCorners(imgLib.Image binImage) {
    int l = binImage.length;
    int width = binImage.width;
    double boundingAngle = 0;
    double maxScore = 0;

    List<int> boundaryCoverageArray = List.filled(181, 0);
    List<int> boxAreaArray = List.filled(181, 0);

    int minBoxArea = l;
    int maxBoxArea = 0;

    int minBoundaryCoverage = l;
    int maxBoundaryCoverage = 0;

    imgLib.Image rotated = binImage;

    int minAngle = -90;
    int maxAngle = 90;

    for (int angle = minAngle; angle <= maxAngle; angle++) {
      rotated = rotate(binImage, angle.toDouble() / 2);
      List<int> delimiters = _getAxisDelimiters(rotated);

      boxAreaArray[angle - minAngle] =
          (delimiters[2] - delimiters[0]) * (delimiters[3] - delimiters[1]);

      if (boxAreaArray[angle - minAngle] < minBoxArea) {
        minBoxArea = boxAreaArray[angle - minAngle];
      } else if (maxBoxArea < boxAreaArray[angle - minAngle]) {
        maxBoxArea = boxAreaArray[angle - minAngle];
      }

      boundaryCoverageArray[angle - minAngle] =
          _getBoundaryCoverage(rotated, delimiters, 1);
      if (boundaryCoverageArray[angle - minAngle] < minBoundaryCoverage) {
        minBoundaryCoverage = boundaryCoverageArray[angle - minAngle];
      } else if (maxBoundaryCoverage <
          boundaryCoverageArray[angle - minAngle]) {
        maxBoundaryCoverage = boundaryCoverageArray[angle - minAngle];
      }

      // double score = coverage / field;
      // double score = (boundaryCoverage * boxToImageRatio) + (1 - boxToImageRatio);
      // double score = boundaryCoverage + (1 - boxToImageRatio);
      // double score = (l / field);

      // if (score > maxScore) {
      //   print(angle);
      //   print(score);
      //   print(boxToImageRatio);
      //   print(boundaryCoverage);
      //   maxScore = score;
      //   boundingAngle = angle;
      //   result = rotated;
      // }
    }

    List<double> normalizedBoundaryCoverageArray = List.filled(181, 0);
    List<double> normalizedBoxAreaArray = List.filled(181, 0);

    for (int i = 0; i <= 180; i++) {
      normalizedBoxAreaArray[i] = (boxAreaArray[i] - minBoxArea).toDouble() /
          (maxBoxArea - minBoxArea).toDouble();
      normalizedBoundaryCoverageArray[i] =
          (boundaryCoverageArray[i] - minBoundaryCoverage).toDouble() /
              (maxBoundaryCoverage - minBoundaryCoverage).toDouble();
      double score =
          (1 - normalizedBoxAreaArray[i]) * normalizedBoundaryCoverageArray[i];
      if (score > maxScore) {
        // print((i + minAngle).toDouble() / 2);
        // print(score);
        // print(boxAreaArray[i]);
        // print(normalizedBoxAreaArray[i]);
        // print(boundaryCoverageArray[i]);
        // print(normalizedBoundaryCoverageArray[i]);
        maxScore = score;
        boundingAngle = (i + minAngle).toDouble() / 2;
      }
    }

    rotated = rotate(binImage, boundingAngle);
    List<int> delimiters = _getAxisDelimiters(rotated);
    // result = drawPoint(result, delimiters[0], delimiters[1], 3);
    // result = drawPoint(result, delimiters[0], delimiters[3], 3);
    // result = drawPoint(result, delimiters[2], delimiters[1], 3);
    // result = drawPoint(result, delimiters[2], delimiters[3], 3);
    // return result;

    List<imgLib.Point> rotatedBoxCorners = List.from([
      imgLib.Point(delimiters[0], delimiters[1]),
      imgLib.Point(delimiters[0], delimiters[3]),
      imgLib.Point(delimiters[2], delimiters[1]),
      imgLib.Point(delimiters[2], delimiters[3]),
    ]);

    List<imgLib.Point> unRotatedBoxCorners =
        rotatePixels(rotated, rotatedBoxCorners, boundingAngle);

    imgLib.Image result = binImage.clone();

    for (final p in unRotatedBoxCorners) {
      result = drawPoint(result, p.xi, p.yi, 3);
    }
    return result;
  }

  static imgLib.Image drawPoint(imgLib.Image img, int x0, int y0, int size) {
    for (int x = -size; x < size; x++) {
      for (int y = -size; y < size; y++) {
        try {
          img.setPixelRgb(x + x0, y + y0, 0, 255, 0);
        } catch (e) {
          continue;
        }
      }
    }
    return img;
  }
}
