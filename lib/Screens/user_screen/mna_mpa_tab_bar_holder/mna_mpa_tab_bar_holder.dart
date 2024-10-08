import 'package:flutter/material.dart';
import 'package:vote_tracker/Screens/user_screen/mna_mpa_tab_bar_holder/mna_vote_screen.dart';
import 'package:vote_tracker/Screens/user_screen/mna_mpa_tab_bar_holder/mpa_vote_screen.dart';

class MNAMPATabBarHolder extends StatefulWidget {
  final String userDistrict;

  const MNAMPATabBarHolder({super.key, required this.userDistrict});

  @override
  State<MNAMPATabBarHolder> createState() => _MNAMPATabBarHolderState();
}

class _MNAMPATabBarHolderState extends State<MNAMPATabBarHolder>
    with SingleTickerProviderStateMixin {
  TabController? controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Votify"),
        centerTitle: true,
        leading: const Icon(Icons.notifications),
        bottom: TabBar(
          controller: controller,
          tabs: const [
            Tab(text: "MNA"),
            Tab(text: "MPA"),
          ],
        ),
      ),
      body: TabBarView(
        controller: controller,
        children: [
          MnaVoteScreen(userDistrict: widget.userDistrict),
          MpaVoteScreen(userDistrict: widget.userDistrict),
        ],
      ),
    );
  }
}
