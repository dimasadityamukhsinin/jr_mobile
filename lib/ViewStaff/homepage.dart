import 'package:flutter/material.dart';
import 'PageOne.dart';
import 'PageTwo.dart';

class HomePageStaff extends StatelessWidget {
  final VoidCallback keluar;
  HomePageStaff(this.keluar);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BottomNavBar(keluar),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  final VoidCallback keluar;
  BottomNavBar(this.keluar);

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> with AutomaticKeepAliveClientMixin<BottomNavBar> {
  bool get wantKeepAlive => true;

  PageController _pageController;
  int _page = 0;

  keluar() {
    setState(() {
      widget.keluar();
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }


  void navigationTapped(int page) {
    // Animating to the page.
    // You can use whatever duration and curve you like
    _pageController.animateToPage(page,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onPageChanged(int page) {
    setState(() {
      this._page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new PageView(
        children: [
          PageOneStaff(keluar),
          PageTwoStaff(keluar),
        ],
        onPageChanged: onPageChanged,
        controller: _pageController,
      ),
      bottomNavigationBar: new Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(width: 2, color: Colors.grey[200]))),
          child: BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.home,
                ),
                title: new Text(
                  "Home",
                )),
            new BottomNavigationBarItem(
                icon: new Icon(
                  Icons.assignment,
                ),
                title: new Text(
                  "Task",
                )),
          ],
          onTap: navigationTapped,
          currentIndex: _page,
          
        fixedColor: Color(0xFF1FB499),
        unselectedItemColor: Color(0xFFBEC6D0),
        ),
      ),
    );
  }
}
