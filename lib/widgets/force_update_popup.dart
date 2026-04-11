import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ForceUpdateDialog extends StatelessWidget {
  final String message;
  final String storeUrl;

  const ForceUpdateDialog({
    required this.message,
    required this.storeUrl,
    super.key,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    required String storeUrl,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // cannot tap outside to dismiss
      builder: (_) => ForceUpdateDialog(
        message: message,
        storeUrl: storeUrl,
      ),
    );
  }

  Future<void> _openStore() async {
    final uri = Uri.parse(storeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // back button disabled
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update, color: Colors.blue),
            SizedBox(width: 8),
            Text('Update Required'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton.icon(
            onPressed: _openStore,
            icon: const Icon(Icons.download),
            label: const Text('Update Now'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
        ],
      ),
    );
  }
}