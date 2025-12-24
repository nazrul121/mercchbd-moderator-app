import 'dart:math';
import 'package:flutter/material.dart';

class FloatingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;
  final Duration duration;
  final double startX; // horizontal start position (0 to 1)
  final double startY; // vertical start position (0 to 1)

  const FloatingIcon({
    Key? key,
    required this.icon,
    required this.size,
    required this.color,
    required this.duration,
    required this.startX,
    required this.startY,
  }) : super(key: key);

  @override
  _FloatingIconState createState() => _FloatingIconState();
}

class _FloatingIconState extends State<FloatingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationY;
  late Animation<double> _animationX;
  late Random random;

  @override
  void initState() {
    super.initState();
    random = Random();

    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    // Y moves up and down by 20 pixels
    _animationY = Tween<double>(
      begin: widget.startY,
      end: widget.startY - 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // X moves left-right by random small amount (optional)
    _animationX = Tween<double>(
      begin: widget.startX,
      end: widget.startX + (random.nextDouble() * 0.04 - 0.02),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      builder: (_, child) {
        return Positioned(
          left: MediaQuery.of(context).size.width * _animationX.value,
          top: MediaQuery.of(context).size.height * _animationY.value,
          child: Opacity(
            opacity: 0.15, // light opacity for subtlety
            child: Icon(widget.icon, size: widget.size, color: widget.color),
          ),
        );
      },
    );
  }
}
