import 'package:flutter/widgets.dart';
import 'package:qms_revamped_content_desktop_client/core/init/service/init_service.dart';

class InitViewModel extends ChangeNotifier {
  late final InitService _initService;

  String message = "Initializing...";
  bool finished = false;

  InitViewModel({required InitService initService}) {
    _initService = initService;
  }

  void init() {
    _initService.init().listen(
      (event) {
        message = event;
        notifyListeners();
      },
      onDone: () {
        finished = true;
        notifyListeners();
      },
    );
  }
}
