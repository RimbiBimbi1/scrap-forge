import 'package:scrap_forge/db_entities/product.dart';

class DimensionFormatter {
  static toLxWxH(Dimensions? dims) {
    if (dims == null) return '';
    String lStr = dims.length != null
        ? '${dims.length}${dims.lengthDisplayUnit!.abbr} x '
        : '';
    String wStr = dims.width != null
        ? '${dims.width}${dims.widthDisplayUnit!.abbr} x '
        : '';
    String hStr = dims.height != null
        ? '${dims.height}${dims.heightDisplayUnit!.abbr} x '
        : '';
    String joined = '$lStr$wStr$hStr';
    return joined.substring(0, joined.length - 2);
  }
}
