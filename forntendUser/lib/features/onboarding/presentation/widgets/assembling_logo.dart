import 'package:flutter/material.dart';

/// The mark assembles from diagonal slices of the artwork itself.
///
/// The slices are cut from the real asset rather than redrawn, so the logo that
/// lands is exactly the logo, down to the overlap where the two chevrons cross.
class AssemblingLogo extends StatelessWidget {
  const AssemblingLogo({
    super.key,
    required this.progress,
    this.size = 180,
    this.slices = 5,
    this.asset = 'assets/images/logosplash.png',
  });

  /// 0 scattered, 1 assembled.
  final Animation<double> progress;
  final double size;
  final int slices;
  final String asset;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(asset, width: size, height: size, fit: BoxFit.contain);

    return SizedBox(
      width: size,
      height: size,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          return Stack(
            children: List.generate(slices, (i) {
              // Slices land one after another rather than together, which is
              // what makes it read as assembly instead of a single fade.
              final start = i / (slices + 2);
              final t = Curves.easeOutBack.transform(
                ((progress.value - start) / (1 - start)).clamp(0.0, 1.0),
              );

              // Odd slices arrive from the opposite corner, so the pieces meet
              // rather than sweeping past each other.
              final from = i.isEven ? -1.0 : 1.0;
              final travel = (1 - t) * size * 0.9 * from;

              return Opacity(
                // Fades on a plain curve so nothing flickers while easeOutBack
                // overshoots.
                opacity: ((progress.value - start) / (1 - start)).clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(travel, travel),
                  child: ClipPath(
                    clipper: _DiagonalSlice(index: i, total: slices),
                    child: image,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

/// One diagonal band of the box: the points where x + y falls in this slice's
/// share of the range. Together the bands tile the whole mark with no seams.
class _DiagonalSlice extends CustomClipper<Path> {
  const _DiagonalSlice({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Path getClip(Size size) {
    final span = size.width + size.height;

    // Neighbouring bands overlap by a hair. Butted edges leave a pale seam
    // where the anti-aliased boundaries do not quite meet.
    const bleed = 1.0;
    final start = span * index / total - bleed;
    final end = span * (index + 1) / total + bleed;

    return Path()
      ..moveTo(start, 0)
      ..lineTo(end, 0)
      ..lineTo(0, end)
      ..lineTo(0, start)
      ..close();
  }

  @override
  bool shouldReclip(_DiagonalSlice oldClipper) =>
      oldClipper.index != index || oldClipper.total != total;
}
