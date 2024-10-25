import 'package:flutter/material.dart';
import 'package:vote_tracker/Screens/Admin_Panel/add_candidate_screen.dart';
import 'package:vote_tracker/Screens/Admin_Panel/start_election_screen.dart';
import 'package:vote_tracker/Screens/user_screen/tab_bar_screens/result_screen.dart';

class BottomNavBarOfAdmin extends StatefulWidget {
  const BottomNavBarOfAdmin({super.key});

  @override
  State<BottomNavBarOfAdmin> createState() => _BottomNavBarOfAdminState();
}

class _BottomNavBarOfAdminState extends State<BottomNavBarOfAdmin> {
  int _selectedIndex = 0;

  final List<Widget> screens = [
    const StartElectionScreen(),
    const AddCandidateScreen(),
    const ResultScreen(
      userDistrict: "Hangu",
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 0) {
          return true;
        } else {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
      },
      child: Scaffold(
        body: screens[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10),
              topLeft: Radius.circular(10),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 5),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              currentIndex: _selectedIndex,
              items: [
                BottomNavigationBarItem(
                  icon: _selectedIndex == 0
                      ? Image.asset("assets/home.png")
                      : Image.asset("assets/unSelectedHome.png"),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 1
                      ? Image.asset("assets/selectedVoting.png")
                      : Image.asset("assets/vote.png"),
                  label: "",
                ),
                BottomNavigationBarItem(
                  icon: _selectedIndex == 2
                      ? Image.asset("assets/selectedResult.png")
                      : Image.asset("assets/result.png"),
                  label: "",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
