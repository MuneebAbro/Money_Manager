import 'package:flutter/material.dart';

/// Lightweight immediate fade-in — no staggered delay, no jitter.
/// The [index] param is kept for API compatibility but no longer drives delay.
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final int index;

  const AnimatedCard({
    super.key,
    required this.child,
    this.index = 0,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _opacity, child: widget.child);
  }
}
