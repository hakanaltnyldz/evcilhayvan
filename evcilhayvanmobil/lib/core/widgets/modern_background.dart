import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A reusable gradient background with subtle floating blobs for a modern look.
class ModernBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final Alignment begin;
  final Alignment end;

  const ModernBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = colors ?? [
      Theme.of(context).colorScheme.primary.withOpacity(0.18),
      Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.16),
      Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.22),
    ];

    final accentColor = Theme.of(context).colorScheme.primary.withOpacity(0.12);
    final secondaryAccent =
        Theme.of(context).colorScheme.secondary.withOpacity(0.08);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: begin,
          end: end,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -60,
            child: _Blob(
              diameter: 240,
              color: accentColor,
            ),
          ),
          Positioned(
            bottom: -100,
            left: -40,
            child: _Blob(
              diameter: 200,
              color: secondaryAccent,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final double diameter;
  final Color color;

  const _Blob({required this.diameter, required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: math.pi / 10,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0)],
          ),
        ),
      ),
    );
  }
}
