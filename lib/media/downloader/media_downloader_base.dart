import 'package:openapi/api.dart' show MediaDto;

abstract class MediaDownloaderBase {
  Future<int> downloadAll({int size = 9999});

  Future<void> downloadOne(MediaDto dto);
}
