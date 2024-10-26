import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vote_tracker/reusable_widgets/my_form.dart';

class AddCandidateScreen extends StatefulWidget {
  const AddCandidateScreen({super.key});

  @override
  State<AddCandidateScreen> createState() => _AddCandidateScreenState();
}

class _AddCandidateScreenState extends State<AddCandidateScreen> {
  TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Votifiy"),
      ),
      body: Padding(
        padding: REdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              height: 12.h,
            ),
            Row(
              children: [
                Flexible(
                  child: MyTextFormField(
                    suffixIcon: Icons.search,
                    controller: _controller,
                    labelText: "Search Candidate",
                    validator: (string) {
                      return null;
                    },
                  ),
                ),
                IconButton.outlined(
                  tooltip: "Add Candidate",
                  color: Colors.blue,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.add,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
