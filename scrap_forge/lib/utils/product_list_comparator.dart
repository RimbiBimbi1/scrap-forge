import 'package:scrap_forge/db_entities/product.dart';

class ProductListComparator {
  static bool compareByLastModifiedTimestamps(
      List<Product> l1, List<Product> l2) {
    if (l1.length != l2.length) return false;
    for (int i = 0; i < l1.length; i++) {
      if (l1[i].lastModifiedTimestamp != l2[i].lastModifiedTimestamp) {
        return false;
      }
    }
    return true;
  }
}
