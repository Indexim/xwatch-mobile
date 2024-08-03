import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:xwatch/pages/auth/login_page.dart';
import 'package:xwatch/pages/dashboard/dashboard_page.dart';
import 'package:xwatch/pages/device/devices_page.dart';

class ProvidedStylesExample extends StatefulWidget {
  const ProvidedStylesExample({
    required this.menuScreenContext,
    super.key,
  });
  final BuildContext menuScreenContext;

  @override
  // ignore: library_private_types_in_public_api
  _ProvidedStylesExampleState createState() => _ProvidedStylesExampleState();
}

class _ProvidedStylesExampleState extends State<ProvidedStylesExample> {
  late PersistentTabController _controller;
  late bool _hideNavBar;
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
  ];

  final NavBarStyle _navBarStyle = NavBarStyle.simple;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _hideNavBar = false;
  }

  @override
  void dispose() {
    for (final element in _scrollControllers) {
      element.dispose();
    }
    super.dispose();
  }

  List<Widget> _buildScreens() => [
    const DashboardPage(),
    const DevicePage(),
  ];

  Color? _getSecondaryItemColorForSpecificStyles() =>
    _navBarStyle == NavBarStyle.style7 ||
    _navBarStyle == NavBarStyle.style10 ||
    _navBarStyle == NavBarStyle.style15 ||
    _navBarStyle == NavBarStyle.style16 ||
    _navBarStyle == NavBarStyle.style17 ||
    _navBarStyle == NavBarStyle.style18 ? Colors.white : null;

  List<PersistentBottomNavBarItem> _navBarsItems() => [
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.screenshot_monitor),
      title: "Dashboard",
      activeColorPrimary: Colors.blue.shade700,
      // activeColorSecondary: _navBarStyle == NavBarStyle.style7 ||
      //         _navBarStyle == NavBarStyle.style10
      //     ? Colors.white
      //     : null,
      inactiveColorPrimary: Colors.grey,
    ),
    PersistentBottomNavBarItem(
      icon: const Icon(Icons.watch_outlined),
      title: "Perangkat",
      activeColorPrimary: Colors.blue,
      inactiveColorPrimary: Colors.grey,
      activeColorSecondary: _getSecondaryItemColorForSpecificStyles(),
    ),
  ];

  @override
  Widget build(final BuildContext context) => 
  Scaffold(
    appBar: AppBar(
      title: Text("X-Watch", style: GoogleFonts.arimo(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Colors.white
      ),),
      // backgroundColor: Colors.grey.shade900,
      backgroundColor: Colors.red,
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: () async {
            SharedPreferences preferences = await SharedPreferences.getInstance();
            await preferences.clear();
            // Navigator.of(context).pushAndRemoveUntil(
            //   CupertinoPageRoute(
            //     builder: (BuildContext context) {
            //       return const LoginPage();
            //     },
            //   ),
            //   (_) => false,
            // );
            Navigator.pushAndRemoveUntil(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
              (route) => false);
          },
          child: const Icon(Icons.logout_outlined, color: Colors.white,),
        )
      ],
    ),
    // // show menu drawer
    // drawer: const Drawer(
    //   child: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         Text("This is the Drawer"),
    //       ],
    //     ),
    //   ),
    // ),
    body: PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: false,
      stateManagement: true,
      hideNavigationBarWhenKeyboardAppears: true,
      popBehaviorOnSelectedNavBarItemPress: PopBehavior.once,
      hideOnScrollSettings: HideOnScrollSettings(
        hideNavBarOnScroll: true,
        scrollControllers: _scrollControllers,
      ),
      padding: EdgeInsets.only(top: 4.sp, bottom: 4.sp),
      // // show floating button
      // floatingActionButton: IconButton(
      //   icon: Container(
      //     padding: const EdgeInsets.all(12),
      //     decoration: const BoxDecoration(
      //         shape: BoxShape.circle, color: Colors.orange),
      //     child: const Icon(
      //       Icons.add,
      //       color: Colors.white,
      //     ),
      //   ),
      //   onPressed: () {},
      // ),
      // onWillPop: (final context) async {
      //   await showDialog(
      //     context: context ?? this.context,
      //     useSafeArea: true,
      //     builder: (final context) => Container(
      //       height: 50,
      //       width: 50,
      //       color: Colors.white,
      //       child: ElevatedButton(
      //         child: const Text("Close"),
      //         onPressed: () {
      //           Navigator.pop(context);
      //         },
      //       ),
      //     ),
      //   );
      //   return false;
      // },
      selectedTabScreenContext: (final context) {
        // testContext = context;
      },
      decoration: NavBarDecoration(
        border: Border.all(color: Colors.redAccent, style: BorderStyle.solid, width: .4.sp),
        borderRadius: BorderRadius.all(Radius.circular(8.sp))
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      backgroundColor: Colors.white,
      isVisible: !_hideNavBar,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          // Navigation Bar's items animation properties.
          duration: Duration(milliseconds: 400),
          curve: Curves.bounceIn,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          // Screen transition animation on change of selected tab.
          animateTabTransition: true,
          duration: Duration(milliseconds: 300),
          screenTransitionAnimationType:
              ScreenTransitionAnimationType.fadeIn,
        ),
        onNavBarHideAnimation: OnHideAnimationSettings(
          duration: Duration(milliseconds: 100),
          curve: Curves.bounceInOut,
        ),
      ),
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      navBarStyle: _navBarStyle, // Choose the nav bar style with this property
    ),
  );
}