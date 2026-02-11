import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qms_revamped_content_desktop_client/core/server_properties/test/ui/screen/server_properties_dialog_stress_screen.dart';

void main() {
  testWidgets('server properties dialog can be closed with Esc repeatedly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: ServerPropertiesDialogStressScreen()),
    );

    final openDialogButton = find.byKey(
      ServerPropertiesDialogStressScreen.openDialogButtonKey,
    );

    for (var i = 0; i < 40; i++) {
      await tester.tap(openDialogButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      expect(
        find.byKey(ServerPropertiesDialogStressScreen.dialogKey),
        findsOneWidget,
        reason: 'Dialog should be visible at cycle ${i + 1}',
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 240));

      expect(
        find.byKey(ServerPropertiesDialogStressScreen.dialogKey),
        findsNothing,
        reason: 'Dialog should be closed at cycle ${i + 1}',
      );

      expect(
        tester.takeException(),
        isNull,
        reason: 'No framework exception expected at cycle ${i + 1}',
      );

      await tester.pump(const Duration(milliseconds: 120));
    }
  });
}
