import 'dart:ffi';
import 'dart:math' as math;

import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as imgLib;
import 'package:scrap_forge/measure_tool/CornerScanner.dart';

class ImageProcessor {
  imgLib.Image image;

  int w = 0;
  int h = 0;

  ImageProcessor(this.image) {
    w = image.width;
    h = image.height;
  }

  imgLib.Image getExtendedImage(int frameWidth) {
    imgLib.Image ext =
        imgLib.Image(width: w + (2 * frameWidth), height: h + (2 * frameWidth));
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        ext.setPixel(x + frameWidth, y + frameWidth, image.getPixel(x, y));
      }
    }
    return ext;
  }

  imgLib.Image getGrayscale() {
    imgLib.Image gs = imgLib.Image(width: w, height: h);
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        imgLib.Color pixel = image.getPixel(x, y);
        double gray = pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        gs.setPixelRgb(x, y, gray, gray, gray);
      }
    }
    return gs;
  }

  imgLib.Image getGaussianBlurred({int kernelRadius = 1, double sd = 1.4}) {
    // imgLib.Image gb = getExtendedImage(kernelRadius);
    imgLib.Image gb = imgLib.Image(width: w, height: h);

    List<imgLib.Point> kernel = getKernel(kernelRadius);
    List<double> gaussianMultipliers =
        getGaussianKernelMultipliers(kernel, kernelRadius, sd);

    for (int x = 0; x < w; x++) {
      gb.setPixel(x, 0, image.getPixel(x, 0));
      gb.setPixel(x, h - 1, image.getPixel(x, h - 1));
    }
    for (int y = 1; y < h - 1; y++) {
      gb.setPixel(0, y, image.getPixel(0, y));
      gb.setPixel(w - 1, y, image.getPixel(w - 1, y));
    }

    for (int y = kernelRadius; y < gb.height - kernelRadius; y++) {
      for (int x = kernelRadius; x < gb.width - kernelRadius; x++) {
        double gray = 0.0;

        kernel.asMap().forEach((i, offset) => gray +=
            image.getPixel((x + offset.x).toInt(), (y + offset.y).toInt()).r *
                gaussianMultipliers[i]);

        gray = math.min(gray, 255);

        gb.setPixelRgb(x, y, gray, gray, gray);
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
    imgLib.Image result = imgLib.Image(width: w, height: h);

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

    List<List<double>> G =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
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
    List<List<double>> direction =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        direction[x][y] = math.atan2(ySobel[x][y].abs(), xSobel[x][y].abs());
      }
    }
    return direction;
  }

  List<List<double>> getDirectionalSobel(List<List<int>> kernel) {
    print("getDirectionalSobel");
    //getextededimage

    List<List<double>> gradient =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));

    // imgLib.Image extended = getExtendedImage(1);

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
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

    imgLib.Image supressed = imgLib.Image(width: w, height: h);

    //Radian Thresholds
    double radTh1 = 0.125 * math.pi;
    double radTh3 = 3 * radTh1;
    double radTh5 = 5 * radTh1;
    double radTh7 = 7 * radTh1;

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
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
    imgLib.Image thresholded = imgLib.Image(width: w, height: h);

    double maxRed = getMaxRed();
    double highThreshold = maxRed * highThresholdRatio;
    double lowThreshold = highThreshold * highThresholdRatio;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
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
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
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

    for (int y = kernelRadius; y < h - kernelRadius; y++) {
      for (int x = kernelRadius; x < w - kernelRadius; x++) {
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

          if (pRed == 127) {
            tracked.add(imgLib.Point(p.x + kx, p.y + ky));
          }
        }
      }
    }

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
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

    imgLib.Image eroded = imgLib.Image(width: w, height: h);

    eroded.clear(bg);

    List<imgLib.Point> kernel = getKernel(1, excludeCenter: true);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        for (imgLib.Point neighbour in kernel) {
          int nRed = erodeTo;
          try {
            nRed = image
                .getPixel((x + neighbour.x).toInt(), (y + neighbour.y).toInt())
                .r
                .toInt();
          } catch (ignored) {
            nRed = erodeFrom;
          }
          if (nRed == erodeTo) {
            eroded.setPixelRgb(x, y, erodeTo, erodeTo, erodeTo);
            break;
          }
        }
      }
    }
    return eroded;
  }

  imgLib.Image getFloodfilled() {
    imgLib.Image floodfilled = imgLib.Image.from(image);

    List<imgLib.Point> flooded = List.empty(growable: true);

    for (int i = 0; i < w; i++) {
      flooded.add(imgLib.Point(i, 0));
      flooded.add(imgLib.Point(i, h - 1));
    }
    for (int i = 1; i < h - 1; i++) {
      flooded.add(imgLib.Point(0, i));
      flooded.add(imgLib.Point(w - 1, i));
    }

    while (flooded.isNotEmpty) {
      imgLib.Point p = flooded.removeLast();
      try {
        if (floodfilled.getPixel(p.x.toInt(), p.y.toInt()).r == 0) {
          floodfilled.setPixelRgb(p.x.toInt(), p.y.toInt(), 255, 255, 255);
          if (p.x > 0) flooded.add(imgLib.Point(p.x - 1, p.y));
          if (p.y > 0) flooded.add(imgLib.Point(p.x, p.y - 1));
          if (p.x < w - 1) flooded.add(imgLib.Point(p.x + 1, p.y));
          if (p.y < h - 1) flooded.add(imgLib.Point(p.x, p.y + 1));
        }
      } catch (ignored) {}
    }
    return floodfilled;
  }

  // Future<Void> loadImage(String imgAsset) async {
  //   ByteData data = await rootBundle.load(imgAsset);
  //   processedImage = decodeImage(data.buffer.asUint8List())!;
  // }
  imgLib.Image getInvariant() {
    print("getInvariant");
    imgLib.Image invariant = imgLib.Image(width: w, height: h);

    num l = w * h;

    List<List<num>> X =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));
    List<List<num>> Y =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));
    List<List<num>> XY =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));
    List<List<num>> tempInvariant =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));

    num meanX = 0.0;
    num meanY = 0.0;
    num covXY = 0.0;
    num sumXabs = 0.0;
    num sumYabs = 0.0;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        imgLib.Pixel pixel = image.getPixel(x, y);

        num r = math.max(pixel.r, 1.0);
        num g = math.max(pixel.g, 1.0);
        num b = math.max(pixel.b, 1.0);

        num geoMean = math.pow(r * g * b, 1.0 / 3.0);

        X[x][y] = math.log(r / geoMean);
        Y[x][y] = math.log(g / geoMean);

        meanX += X[x][y];
        meanY += Y[x][y];
      }
    }

    meanX /= l;
    meanY /= l;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        X[x][y] = X[x][y] - meanX;
        Y[x][y] = Y[x][y] - meanX;
        XY[x][y] = X[x][y] * Y[x][y];
        // covXY += BigDecimal.parse(XY[x][y].toString());
        // sumXabs += BigDecimal.parse(X[x][y].abs().toString());
        // sumYabs += BigDecimal.parse(Y[x][y].abs().toString());
        covXY += XY[x][y];
        sumXabs += X[x][y].abs();
        sumYabs += Y[x][y].abs();
      }
    }

    num alpha = (math.pi / 2) - (acot(covXY.sign) * (sumYabs / sumXabs));

    num maxI = -double.infinity;
    num minI = double.infinity;

    num sin = math.sin(alpha);
    num cos = math.cos(alpha);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        tempInvariant[x][y] = (X[x][y] * cos) + (Y[x][y] * sin);

        if (maxI < tempInvariant[x][y]) {
          maxI = tempInvariant[x][y];
        } else if (minI > tempInvariant[x][y]) {
          minI = tempInvariant[x][y];
        }
      }
    }

    minI *= 1.025;
    maxI *= 0.975;

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        if (tempInvariant[x][y] > maxI) {
          tempInvariant[x][y] = maxI;
        } else if (tempInvariant[x][y] < minI) {
          tempInvariant[x][y] = minI;
        }

        num gray = (tempInvariant[x][y] - minI) / (maxI - minI) * 255;

        invariant.setPixelRgb(x, y, gray, gray, gray);
      }
    }
    return invariant;
  }

  num acot(num x) {
    if (x < 0) {
      return -math.atan(x) - math.pi / 2;
    }
    if (x > 0) {
      return math.pi / 2 - math.atan(x);
    }
    return 0;
  }
}
