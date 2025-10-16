
import 'package:flutter/material.dart';
import 'package:iconnect/app_palette.dart';
import 'package:iconnect/constant/constant.dart';

class AppDrawer extends StatelessWidget {

  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppPalette.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.antiAlias,
      width: 270,
      child: SafeArea(
        child: Column(
          children: [
            ConstantWidgets.hight20(context),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.assignment_outlined),
                    title: Text('Add PDI Entry'),
                    onTap: () {
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.policy_outlined),
                    title: Text('Terms and conditions'),
                    onTap: () {}
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: Text('Privacy Policy'),
                    onTap: () {
                      
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: Text('Delete account'),
                    onTap: () {
                      
                    },
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                   ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () {
                      },
                    ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Version 1.0.0",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
