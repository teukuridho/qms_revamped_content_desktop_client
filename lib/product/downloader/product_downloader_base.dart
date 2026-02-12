import 'package:openapi/api.dart' show ProductDto;

abstract class ProductDownloaderBase {
  Future<int> downloadAll({int size = 9999});

  Future<void> downloadOne(ProductDto dto);
}
