import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vote_tracker/Screens/auth_screens/login_screen.dart';
import 'package:vote_tracker/constants.dart';
import 'package:lottie/lottie.dart';

class BoardingScreen extends StatefulWidget {
  const BoardingScreen({super.key});

  @override
  State<BoardingScreen> createState() => _BoardingScreenState();
}

class _BoardingScreenState extends State<BoardingScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<Widget> pages = [
    const BoardingPage(
      title: boardingTitle1,
      description: boardingDescription1,
      lottie: boardingLottie1,
    ),
    const BoardingPage(
      title: boardingTitle2,
      description: boardingDescription2,
      lottie: boardingLottie2,
    ),
    const BoardingPage(
      title: boardingTitle3,
      description: boardingDescription3,
      lottie: boardingLottie3,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ),
          _buildDotIndicator(),
        ],
      ),
      floatingActionButton: _currentPage == pages.length - 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xff006600),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildDotIndicator() {
    return Padding(
      padding: REdgeInsets.only(bottom: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          pages.length,
          (index) => Container(
            width: 10,
            height: 10,
            margin: REdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  index == _currentPage ? const Color(0xff006600) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class BoardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String lottie;

  const BoardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.lottie,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: REdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: ScreenUtil().setHeight(200),
            width: ScreenUtil().setWidth(200),
            child: Lottie.asset(lottie, animate: true, fit: BoxFit.contain),
          ),
          SizedBox(height: ScreenUtil().setHeight(30)),
          Text(
            title,
            style: TextStyle(
              fontSize: 24.0.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ScreenUtil().setHeight(30)),
          Text(
            description,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(16),
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
