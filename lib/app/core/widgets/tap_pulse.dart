import 'package:flutter/material.dart';

/// Brief scale pulse on tap. Works independently of haptic feedback, so every
/// control still confirms itself visually when vibrations are off or the
/// device cannot vibrate.
class TapPulse extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  const TapPulse({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.92,
    this.duration = const Duration(milliseconds: 90),
  });

  @override
  State<TapPulse> createState() => _TapPulseState();
}

class _TapPulseState extends State<TapPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
    lowerBound: 0.0,
    upperBound: 1.0,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 1.0,
    end: widget.scale,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      if (mounted) _controller.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
