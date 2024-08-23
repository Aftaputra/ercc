import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            currentIndex == 0 ? 'assets/home_active.svg' : 'assets/home_idle.svg',
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            currentIndex == 1 ? 'assets/stats_active.svg' : 'assets/stats_idle.svg',
          ),
          label: 'Stats',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            currentIndex == 2 ? 'assets/tune_active.svg' : 'assets/tune_idle.svg',
          ),
          label: 'Tune',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            currentIndex == 3 ? 'assets/etc_active.svg' : 'assets/etc_idle.svg',
          ),
          label: 'Etc',
        ),
      ],
    );
  }
}
