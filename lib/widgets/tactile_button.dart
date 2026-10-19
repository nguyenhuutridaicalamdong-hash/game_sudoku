import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class TactileButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color backgroundColor;
  final Color shadowColor;
  final double height;
  final double depth;
  final BorderRadius borderRadius;

  const TactileButton({
    super.key,
    required this.onPressed,
    required this.child,
    required this.backgroundColor,
    required this.shadowColor,
    this.height = 56,
    this.depth = 6,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  State<TactileButton> createState() => _TactileButtonState();
}

class _TactileButtonState extends State<TactileButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        AudioService.playTap();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 60),
        height: widget.height,
        margin: EdgeInsets.only(top: _isPressed ? widget.depth : 0),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: widget.borderRadius,
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: Offset(0, widget.depth),
                    blurRadius: 0,
                  ),
                  BoxShadow(
                    color: widget.shadowColor.withOpacity(0.35),
                    offset: Offset(0, widget.depth + 4),
                    blurRadius: 16,
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
