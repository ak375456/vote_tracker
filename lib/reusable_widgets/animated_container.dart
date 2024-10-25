import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FancyContainer extends StatefulWidget {
  final Size size;
  final Duration cycle;
  final List<Color> colors;

  const FancyContainer({
    super.key,
    required this.size,
    required this.cycle,
    required this.colors,
  });

  @override
  State<FancyContainer> createState() => FancyContainerState();
}

class FancyContainerState extends State<FancyContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: widget.cycle,
      vsync: this,
    );
  }

  // Expose startAnimation function to control animation externally
  void startAnimation() {
    controller.forward();
    controller.addListener(() {
      if (controller.isCompleted) {
        controller.repeat();
      }
    });

    // Stop animation after 3 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        controller.stop();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aspectRatio = widget.size.height / widget.size.width;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Stack(
          children: [
            Container(
              width: widget.size.width,
              height: widget.size.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(360),
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  begin: Alignment.center,
                  end: Alignment.topRight,
                  transform: SlideGradient(
                    controller.value,
                    widget.size.height * aspectRatio,
                  ),
                  colors: widget.colors,
                ),
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Start",
                  style: TextStyle(fontSize: 24.sp, color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SlideGradient implements GradientTransform {
  final double value;
  final double offset;
  const SlideGradient(this.value, this.offset);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    final dist = value * (bounds.width + offset);
    return Matrix4.identity()..translate(-dist);
  }
}
