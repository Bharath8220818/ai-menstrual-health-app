import 'package:flutter/material.dart';

class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.radius = 16,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + (_controller.value * 2.4), 0),
              end: Alignment(1.0 + (_controller.value * 2.4), 0),
              colors: const [
                Color(0xFFF6DCE6),
                Color(0xFFFDE8EF),
                Color(0xFFF6DCE6),
              ],
            ),
          ),
        );
      },
    );
  }
}
