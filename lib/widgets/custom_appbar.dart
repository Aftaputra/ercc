import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;

  CustomAppBar({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _getAppBarTitle(),
      centerTitle: true,
      backgroundColor: Colors.white,
      toolbarHeight: 56.0,
      actions: [_getAppBarIcon()],
    );
  }

  Widget _getAppBarIcon() {
    switch (currentIndex) {
      case 0:
        return Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Image.asset(
            'assets/db_appbar.png',
            fit: BoxFit.contain,
          ),
        );
      case 1:
        return Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Image.asset(
            'assets/sts_appbar.png',
            fit: BoxFit.contain,
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Image.asset(
            'assets/tune_appbar.png',
            fit: BoxFit.contain,
          ),
        );
      case 3:
        return Container(); // Atau kasih icon lainnya kalau ada
      default:
        return Container();
    }
  }

  Widget _getAppBarTitle() {
    switch (currentIndex) {
      case 0:
        return Text('Dashboard');
      case 1:
        return Text('Stats');
      case 2:
        return Text('Tune');
      case 3:
        return Text('Etc');
      default:
        return Text('Page');
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(56.0);
}
