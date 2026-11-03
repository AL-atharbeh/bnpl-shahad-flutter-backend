import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

class GlassNavItem {
  const GlassNavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}

/// The customer app's floating frosted bar with its sliding green pill,
/// generalised to any number of tabs. Drag across it to scrub between tabs.
class GlassBottomNav extends StatefulWidget {
  const GlassBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTabChanged,
  });

  final List<GlassNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTabChanged;

  static const double height = 70;

  /// Space content should leave at the bottom so the bar never covers it.
  static double clearance(BuildContext context) =>
      height + 24 + MediaQuery.of(context).padding.bottom;

  @override
  State<GlassBottomNav> createState() => _GlassBottomNavState();
}

class _GlassBottomNavState extends State<GlassBottomNav> {
  late double _progress = widget.currentIndex.toDouble();
  bool _dragging = false;

  int get _count => widget.items.length;

  @override
  void didUpdateWidget(GlassBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex && !_dragging) {
      setState(() => _progress = widget.currentIndex.toDouble());
    }
  }

  void _dragTo(Offset local, double width, bool rtl) {
    final slot = width / _count;
    var progress = (local.dx / slot - 0.5).clamp(0.0, _count - 1.0);
    if (rtl) progress = (_count - 1) - progress;
    if (progress.round() != _progress.round()) HapticFeedback.selectionClick();
    setState(() {
      _progress = progress;
      _dragging = true;
    });
  }

  void _endDrag() {
    final index = _progress.round().clamp(0, _count - 1);
    setState(() {
      _dragging = false;
      _progress = index.toDouble();
    });
    HapticFeedback.lightImpact();
    widget.onTabChanged(index);
  }

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 20,
      right: 20,
      bottom: bottomInset > 0 ? bottomInset : 20,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final slot = width / _count;
          final pillWidth = (slot - 10).clamp(44.0, 72.0);

          return GestureDetector(
            onHorizontalDragUpdate: (d) => _dragTo(d.localPosition, width, rtl),
            onHorizontalDragEnd: (_) => _endDrag(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  height: GlassBottomNav.height,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.82),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      AnimatedPositionedDirectional(
                        duration: Duration(milliseconds: _dragging ? 80 : 450),
                        curve: _dragging ? Curves.linear : Curves.easeOutBack,
                        start: slot * _progress + (slot - pillWidth) / 2,
                        top: 7,
                        width: pillWidth,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: AppColors.pillGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryLight.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 15,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          for (var i = 0; i < _count; i++) _buildItem(i),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = widget.items[index];
    final proximity = (1.0 - (_progress - index).abs()).clamp(0.0, 1.0);
    final color = Color.lerp(
      AppColors.textMuted,
      Colors.white,
      Curves.easeIn.transform(proximity),
    )!;

    return Expanded(
      child: Semantics(
        button: true,
        selected: index == widget.currentIndex,
        label: item.label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() => _progress = index.toDouble());
            widget.onTabChanged(index);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 0.9 + proximity * 0.15,
                child: Icon(item.icon, size: 26, color: color),
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
