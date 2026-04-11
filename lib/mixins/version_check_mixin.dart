import 'package:flutter/material.dart';
import 'package:iconnect/services/version_check_service.dart';
import 'package:iconnect/widgets/force_update_popup.dart';

mixin VersionCheckMixin<T extends StatefulWidget> on State<T> {
  Future<void> checkAppVersion() async {
    final status = await VersionCheckService().checkVersion();

    if (status.needsUpdate && mounted) {
      await ForceUpdateDialog.show(
        context,
        message: status.message!,
        storeUrl: status.storeUrl!,
      );
    }
  }
}
