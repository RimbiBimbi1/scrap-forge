import 'package:image/image.dart' as imgLib;

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
    // from - wektor wierzchołków trójkąta tekstury
    // to - wektor wierzchołków teksturowanego trójkąta wynikowego obrazu
    // textureImg - obraz tekstury
    // canvasImg - obraz wyjściowy
    num det = ((to[1].x - to[0].x) * (to[2].y - to[0].y)) -
        ((to[1].y - to[0].y) * (to[2].x - to[0].x));
    //Dla każdego piksela wynikowego obrazu
    for (int y = 0; y < canvasImg.height; y++) {
      for (int x = 0; x < canvasImg.width; x++) {
        //Oblicz współrzędne barycentryczne względem wynikowego trójkąta
        num v = ((x - to[0].x) * (to[2].y - to[0].y) -
                (y - to[0].y) * (to[2].x - to[0].x)) /
            det;
        num w = ((y - to[0].y) * (to[1].x - to[0].x) -
                (x - to[0].x) * (to[1].y - to[0].y)) /
            det;
        num u = 1.0 - v - w;
        //Jeżeli piksel znajduje się wewnątrz trójkąta:
        if (0 <= u && 1 >= u && 0 <= v && 1 >= v && 0 <= w && 1 >= w) {
          //Oblicz współrzędne kartezjańskie odpowiadającego mu piksela tekstury i zaokrąglij
          int xT = (u * from[0].x + v * from[1].x + w * from[2].x).floor();
          int yT = (u * from[0].y + v * from[1].y + w * from[2].y).floor();
          //Jeżeli obliczone współrzędne znajdują się w obrębie obrazu
          if ((xT > 0) &&
              (xT < textureImg.width) &&
              (yT > 0) &&
              (yT < textureImg.height)) {
            //Przypisz piksel tekstury do piksela wyniku
            canvasImg.setPixel(
              x,
              y,
              textureImg.getPixel(xT, yT),
            );
          }
        }
      }
    }
  }
}
