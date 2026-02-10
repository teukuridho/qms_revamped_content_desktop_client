import 'package:openapi/api.dart' show MediaDto;

abstract class MediaDownloaderBase {
  Future<void> downloadOne(MediaDto dto);
}
