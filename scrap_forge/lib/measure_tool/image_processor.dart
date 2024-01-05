import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as imgLib;

class ImageProcessor {
  static imgLib.Image getGaussianBlurred(imgLib.Image image,
      {int kernelRadius = 1, double sd = 1.4}) {
    int w = image.width;
    int h = image.height;
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
            image.getPixel((x + offset.xi), (y + offset.yi)).r *
                gaussianMultipliers[i]);

        gray = math.min(gray, 255);

        gb.setPixelRgb(x, y, gray, gray, gray);
      }
    }
    return gb;
  }

  static List<double> getGaussianKernelMultipliers(
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

  static imgLib.Image getSobel(imgLib.Image image, List<List<double>> xSobel,
      List<List<double>> ySobel) {
    int w = image.width;
    int h = image.height;
    imgLib.Image result = imgLib.Image(width: w, height: h);

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

  static List<List<double>> getSobelDirection(imgLib.Image image,
      List<List<double>> xSobel, List<List<double>> ySobel) {
    int w = image.width;
    int h = image.height;
    List<List<double>> direction =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        direction[x][y] = math.atan2(ySobel[x][y].abs(), xSobel[x][y].abs());
      }
    }
    return direction;
  }

  static List<List<double>> getDirectionalSobel(
      imgLib.Image image, List<List<int>> kernel) {
    int w = image.width;
    int h = image.height;

    List<List<double>> gradient =
        List.generate(w, (int index) => List.generate(h, (int index) => 0.0));

    for (int y = 1; y < h - 1; y++) {
      for (int x = 1; x < w - 1; x++) {
        double gray = 0.0;
        for (int ky = 0; ky < 3; ky++) {
          for (int kx = 0; kx < 3; kx++) {
            gray += kernel[kx][ky] * image.getPixel(x - 1 + kx, y - 1 + ky).r;
          }
        }
        gradient[x][y] = gray;
      }
    }

    return gradient;
  }

  static imgLib.Image getNonMaxSuppressed(
      imgLib.Image image, List<List<double>> direction) {
    int w = image.width;
    int h = image.height;

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

        if (angle < 0) {
          //do nothing
        } else if ((angle < radTh1) || (radTh7 <= angle)) {
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

  static imgLib.Image getDoubleThresholded(imgLib.Image image,
      {double lowThresholdRatio = 0.25, double highThresholdRatio = 0.25}) {
    int w = image.width;
    int h = image.height;
    imgLib.Image thresholded = imgLib.Image(width: w, height: h);

    double maxRed = getMaxRed(image);
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

  static double getMaxRed(
    imgLib.Image image,
  ) {
    int w = image.width;
    int h = image.height;
    double result = 0.0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        double red = image.getPixel(x, y).r.toDouble();
        if (red > result) {
          result = red;
        }
      }
    }
    return result;
  }

  static imgLib.Image getHysteresised(imgLib.Image image,
      {int kernelRadius = 1}) {
    int w = image.width;
    int h = image.height;
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

      result.setPixelRgb(p.xi, p.yi, 255, 255, 255);

      for (int ky = -kernelRadius; ky <= kernelRadius; ky++) {
        for (int kx = -kernelRadius; kx <= kernelRadius; kx++) {
          if (kx == 0 && ky == 0) {
            continue;
          }
          int pRed = result.getPixel((p.xi + kx), (p.yi + ky)).r.toInt();

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

  static List<imgLib.Point> getKernel(int kernelRadius,
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

  static imgLib.Image getDilated(imgLib.Image image, {int radius = 1}) {
    return getEroded(image, erodeTo: 0, radius: 1);
  }

  static imgLib.Image getEroded(imgLib.Image image,
      {int erodeTo = 255, int radius = 1}) {
    int w = image.width;
    int h = image.height;
    int erodeFrom = (255 - erodeTo);
    imgLib.Color bg = imgLib.ColorRgb8(erodeFrom, erodeFrom, erodeFrom);

    imgLib.Image eroded = imgLib.Image(width: w, height: h);

    eroded.clear(bg);

    List<imgLib.Point> kernel = getKernel(radius, excludeCenter: true);

    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        for (imgLib.Point neighbour in kernel) {
          int nRed = erodeTo;
          try {
            nRed = image
                .getPixel((x + neighbour.xi), (y + neighbour.yi))
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

  static imgLib.Image getFloodfilled(
    imgLib.Image image,
  ) {
    int w = image.width;
    int h = image.height;
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
      // try {
      if (floodfilled.getPixel(p.xi, p.yi).r == 0) {
        floodfilled.setPixelRgb(p.xi, p.yi, 255, 255, 255);
        if (p.x > 0) flooded.add(imgLib.Point(p.x - 1, p.y));
        if (p.y > 0) flooded.add(imgLib.Point(p.x, p.y - 1));
        if (p.x < w - 1) flooded.add(imgLib.Point(p.x + 1, p.y));
        if (p.y < h - 1) flooded.add(imgLib.Point(p.x, p.y + 1));
      }
      // } catch (ignored) {}
    }
    return floodfilled;
  }

  static imgLib.Image getBinaryInversed(
    imgLib.Image image,
  ) {
    int w = image.width;
    int h = image.height;
    return imgLib.Image.fromBytes(
        width: w,
        height: h,
        bytes: Uint8List.fromList(image.getBytes().map((e) => 255 - e).toList())
            .buffer);
  }

  static imgLib.Image getInvariant(
    imgLib.Image image,
  ) {
    int w = image.width;
    int h = image.height;
    imgLib.Image invariant = imgLib.Image(width: w, height: h);

    num l = w * h;

    List<List<num>> X = List.generate(w, (int index) => List.filled(h, 0.0));
    List<List<num>> Y = List.generate(w, (int index) => List.filled(h, 0.0));
    List<List<num>> XY = List.generate(w, (int index) => List.filled(h, 0.0));
    List<List<num>> tempInvariant =
        List.generate(w, (int index) => List.filled(h, 0.0));

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
        Y[x][y] = Y[x][y] - meanY;
        XY[x][y] = X[x][y] * Y[x][y];
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

  static num acot(num x) {
    if (x < 0) {
      return -math.atan(x) - math.pi / 2;
    }
    if (x > 0) {
      return math.pi / 2 - math.atan(x);
    }
    return 0;
  }
}
