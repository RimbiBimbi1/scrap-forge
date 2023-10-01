import 'dart:ffi';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:scrap_forge/measure_tool/CornerScanner.dart';

class ImageProcessor {
  imgLib.Image image;

  ImageProcessor(this.image);

  imgLib.Image getExtendedImage(int frameWidth) {
    imgLib.Image ext = imgLib.Image(
        width: image.width + (2 * frameWidth),
        height: image.height + (2 * frameWidth));
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        ext.setPixel(x + frameWidth, y + frameWidth, image.getPixel(x, y));
      }
    }
    return ext;
  }

  imgLib.Image getGrayscale() {
    imgLib.Image gs = imgLib.Image(width: image.width, height: image.height);
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        imgLib.Color pixel = image.getPixel(x, y);
        double grey = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        gs.setPixelRgb(x, y, grey, grey, grey);
      }
    }
    return gs;
  }

  imgLib.Image getGaussianBlurred({int kernelRadius = 1, double sd = 1.4}) {
    // imgLib.Image gb = getExtendedImage(kernelRadius);
    imgLib.Image gb = imgLib.Image(width: image.width, height: image.height);

    List<imgLib.Point> kernel = getKernel(kernelRadius);
    List<double> gaussianMultipliers =
        getGaussianKernelMultipliers(kernel, kernelRadius, sd);

    for (int y = kernelRadius; y < gb.height - kernelRadius; y++) {
      for (int x = kernelRadius; x < gb.width - kernelRadius; x++) {
        double grey = 0.0;

        kernel.asMap().forEach((i, point) => grey +=
            image.getPixel((x + point.x).toInt(), (y + point.y).toInt()).r *
                gaussianMultipliers[i]);

        gb.setPixelRgb(x, y, grey, grey, grey);
      }
    }
    return gb;
  }

  List<double> getGaussianKernelMultipliers(
      List<imgLib.Point> kernel, radius, sd) {
    List<double> gaussianKernel = List.empty(growable: true);
    double mulltiplier = 1 / (2 * math.pi * sd * sd);
    double sum = 0.0;

    for (var point in kernel) {
      double exponent = -((point.x - radius) * (point.x + radius) +
              (point.y - radius) * (point.y + radius)) /
          (2 * sd * sd);
      gaussianKernel.add(mulltiplier * math.exp(exponent));
      sum += gaussianKernel.last;
    }

    return gaussianKernel.map((e) => e / sum).toList();
  }

  imgLib.Image getSobel(List<List<double>> xSobel, List<List<double>> ySobel) {
    print("getSobel");
    imgLib.Image result =
        imgLib.Image(width: image.width, height: image.height);

    // List<List<int>> Kx = [
    //   [-1, 0, 1],
    //   [-2, 0, 2],
    //   [-1, 0, 1]
    // ];
    // List<List<int>> Ky = [
    //   [1, 2, 1],
    //   [0, 0, 0],
    //   [-1, -2, -1]
    // ];

    // List<List<double>> xSobel = getDirectionalSobel(Kx);
    // List<List<double>> ySobel = getDirectionalSobel(Ky);

    List<List<double>> G = List.generate(image.width,
        (int index) => List.generate(image.height, (int index) => 0.0));

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        G[x][y] = math
            .sqrt(xSobel[x][y] * xSobel[x][y] + ySobel[x][y] * ySobel[x][y]);
        double gray = math.max(0, math.min(255, G[x][y]));
        result.setPixelRgb(x, y, gray, gray, gray);
      }
    }
    return result;
  }

  List<List<double>> getSobelDirection(
      List<List<double>> xSobel, List<List<double>> ySobel) {
    print("getSobelDirection");
    List<List<double>> direction = List.generate(image.width,
        (int index) => List.generate(image.height, (int index) => 0.0));

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        direction[x][y] = math.atan2(ySobel[x][y].abs(), xSobel[x][y].abs());
      }
    }
    return direction;
  }

  List<List<double>> getDirectionalSobel(List<List<int>> kernel) {
    print("getDirectionalSobel");
    //getextededimage

    List<List<double>> gradient = List.generate(image.width,
        (int index) => List.generate(image.height, (int index) => 0.0));

    // imgLib.Image extended = getExtendedImage(1);

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        double gray = 0.0;
        for (int ky = 0; ky < 3; ky++) {
          for (int kx = 0; kx < 3; kx++) {
            gray += kernel[kx][ky] * image.getPixel(x - 1 + kx, y - 1 + ky).r;
          }
        }
        // gradient[x][y] = math.min(255, math.max(0, gray));
        gradient[x][y] = gray;
      }
    }

    return gradient;
  }

  imgLib.Image getNonMaxSuppression(List<List<double>> direction) {
    print("getNonMaxSuppression");

    imgLib.Image supressed =
        imgLib.Image(width: image.width, height: image.height);

    //Radian Thresholds
    double radTh1 = 0.125 * math.pi;
    double radTh3 = 3 * radTh1;
    double radTh5 = 5 * radTh1;
    double radTh7 = 7 * radTh1;

    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        num q = 255.0;
        num r = 255.0;

        double angle = direction[x][y];

        try {
          if (angle < 0) {
            throw Exception();
          }
          if ((angle < radTh1) || (radTh7 <= angle)) {
            q = image.getPixel(x, y + 1).r;
            r = image.getPixel(x, y - 1).r;
          } else if (angle < radTh3) {
            q = image.getPixel(x + 1, y - 1).r;
            r = image.getPixel(x - 1, y + 1).r;
          } else if (angle < radTh5) {
            q = image.getPixel(x + 1, y).r;
            r = image.getPixel(x - 1, y).r;
          } else if (angle < radTh7) {
            q = image.getPixel(x - 1, y - 1).r;
            r = image.getPixel(x + 1, y + 1).r;
          }
        } catch (exception) {
          q = 255.0;
          r = 255.0;
        }

        num gray = image.getPixel(x, y).r;
        if ((gray >= q) && (gray >= r)) {
          supressed.setPixelRgb(x, y, gray, gray, gray);
        } else {
          supressed.setPixelRgb(x, y, 0, 0, 0);
        }
      }
    }
    return supressed;
  }

  imgLib.Image getDoubleThresholded(
      {double lowThresholdRatio = 0.25, double highThresholdRatio = 0.25}) {
    imgLib.Image thresholded =
        imgLib.Image(width: image.width, height: image.height);

    double maxRed = getMaxRed();
    double highThreshold = maxRed * highThresholdRatio;
    double lowThreshold = highThreshold * highThresholdRatio;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        num red = image.getPixel(x, y).r;
        if (red >= highThreshold) {
          thresholded.setPixelRgb(x, y, 255, 255, 255);
        } else if (red >= lowThreshold) {
          thresholded.setPixelRgb(x, y, 127, 127, 127);
        } else {
          thresholded.setPixelRgb(x, y, 0, 0, 0);
        }
      }
    }
    return thresholded;
  }

  double getMaxRed() {
    double result = 0.0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        double red = image.getPixel(x, y).r.toDouble();
        if (red > result) {
          result = red;
        }
      }
    }
    return result.toDouble();
  }

  imgLib.Image getHysteresised({int kernelRadius = 1}) {
    imgLib.Image result = imgLib.Image.from(image);
    List<imgLib.Point> tracked = List.empty(growable: true);

    for (int y = kernelRadius; y < image.height - kernelRadius; y++) {
      for (int x = kernelRadius; x < image.width - kernelRadius; x++) {
        if (image.getPixel(x, y).r.toInt() == 255) {
          tracked.add(imgLib.Point(x, y));
        }
      }
    }

    while (tracked.isNotEmpty) {
      imgLib.Point p = tracked.removeLast();

      result.setPixelRgb(p.x.toInt(), p.y.toInt(), 255, 255, 255);

      for (int ky = -kernelRadius; ky <= kernelRadius; ky++) {
        for (int kx = -kernelRadius; kx <= kernelRadius; kx++) {
          if (kx == 0 && ky == 0) {
            continue;
          }
          int pRed =
              result.getPixel((p.x + kx).toInt(), (p.y + ky).toInt()).r.toInt();
          // print(pRed);

          if (pRed == 127) {
            tracked.add(imgLib.Point(p.x + kx, p.y + ky));
          }
        }
      }
    }

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        int pRed = result.getPixel(x, y).r.toInt();

        if (pRed != 255) {
          result.setPixelRgb(x, y, 0, 0, 0);
        }
      }
    }
    return result;
  }

  List<imgLib.Point> getKernel(int kernelRadius,
      {bool excludeCenter = false, bool round = false}) {
    List<imgLib.Point> kernel = List.empty(growable: true);
    int radius2 = kernelRadius * kernelRadius;
    for (int yOffset = -kernelRadius; yOffset <= kernelRadius; yOffset++) {
      for (int xOffset = -kernelRadius; xOffset <= kernelRadius; xOffset++) {
        if (excludeCenter && xOffset == 0 && yOffset == 0) {
          continue;
        }
        if (round) {
          int distance2 = yOffset * yOffset + xOffset * xOffset;
          if (distance2 > radius2) {
            continue;
          }
        }
        kernel.add(imgLib.Point(xOffset, yOffset));
      }
    }
    return kernel;
  }

  imgLib.Image getDilated() {
    return getEroded(erodeTo: 0);
  }

  imgLib.Image getEroded({erodeTo = 255}) {
    int erodeFrom = (255 - erodeTo).toInt();
    imgLib.Color bg = imgLib.ColorRgb8(erodeFrom, erodeFrom, erodeFrom);

    imgLib.Image eroded =
        imgLib.Image(width: image.width, height: image.height);

    eroded.clear(bg);

    List<imgLib.Point> kernel = getKernel(1, excludeCenter: true);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        for (imgLib.Point neighbour in kernel) {
          try {
            int nRed = image
                .getPixel((x + neighbour.x).toInt(), (y + neighbour.y).toInt())
                .r
                .toInt();
            if (nRed == erodeTo) {
              eroded.setPixelRgb(x, y, erodeTo, erodeTo, erodeTo);
              break;
            }
          } catch (ignored) {}
        }
      }
    }
    return eroded;
  }

  imgLib.Image getFloodfilled() {
    imgLib.Image floodfilled = imgLib.Image.from(image);

    List<imgLib.Point> flooded = List.empty(growable: true);

    for (int i = 0; i < image.width; i++) {
      flooded.add(imgLib.Point(i, 0));
      flooded.add(imgLib.Point(i, image.height - 1));
    }
    for (int i = 1; i < image.height - 1; i++) {
      flooded.add(imgLib.Point(0, i));
      flooded.add(imgLib.Point(image.width - 1, i));
    }

    while (flooded.isNotEmpty) {
      imgLib.Point p = flooded.removeLast();
      try {
        if (floodfilled.getPixel(p.x.toInt(), p.y.toInt()).r == 0) {
          floodfilled.setPixelRgb(p.x.toInt(), p.x.toInt(), 255, 255, 255);
          if (p.y > 0) flooded.add(imgLib.Point(p.x, p.y - 1));
          if (p.x > 0) flooded.add(imgLib.Point(p.x - 1, p.y));
          if (p.x < image.width - 1) flooded.add(imgLib.Point(p.x + 1, p.y));
          if (p.y < image.height - 1) flooded.add(imgLib.Point(p.x, p.y + 1));
        }
      } catch (ignored) {}
    }
    return floodfilled;
  }

  // Future<Void> loadImage(String imgAsset) async {
  //   ByteData data = await rootBundle.load(imgAsset);
  //   processedImage = decodeImage(data.buffer.asUint8List())!;
  // }
}
