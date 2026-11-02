import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Code entry without boxes.
///
/// Six boxes with borders is what every form looks like. Here each slot is a
/// digit sitting on a rule, and a single accent bar glides to whichever slot is
/// next, so the eye is led rather than asked to find the empty box.
class CodeField extends StatefulWidget {
  const CodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.onCompleted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  final _focusNode = FocusNode();

  static const double _slotWidth = 44;
  static const double _slotGap = 10;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focusNode.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focusNode.removeListener(_onChanged);
    _focusNode.dispose();
    super.dispose();
  }

  int get _cursor => widget.controller.text.length.clamp(0, widget.length - 1);

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final isFull = text.length == widget.length;
    final totalWidth = widget.length * _slotWidth + (widget.length - 1) * _slotGap;

    return GestureDetector(
      // The whole row is the target, so a tap anywhere starts typing.
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Holds the real input offstage; the row below is what is seen.
          SizedBox(
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.number,
                enableInteractiveSelection: false,
                showCursor: false,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: (value) {
                  if (value.length == widget.length) {
                    widget.onCompleted?.call(value);
                  }
                },
              ),
            ),
          ),
          Directionality(
            // Codes are read left to right in either language.
            textDirection: TextDirection.ltr,
            child: SizedBox(
              width: totalWidth,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.length, (i) {
                      final filled = i < text.length;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: i == widget.length - 1 ? 0 : _slotGap,
                        ),
                        child: SizedBox(
                          width: _slotWidth,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: 46,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 160),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: ScaleTransition(
                                          scale: Tween<double>(begin: 0.7, end: 1)
                                              .animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: filled
                                        ? Text(
                                            text[i],
                                            key: ValueKey('$i-${text[i]}'),
                                            style: const TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              // The resting rule. The accent bar rides above it.
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 2,
                                decoration: BoxDecoration(
                                  color: filled
                                      ? AppColors.primary.withOpacity(0.35)
                                      : AppColors.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),

                  // One bar for the whole row, sliding to the slot in play.
                  // Following a single moving marker is easier than scanning
                  // six slots for the one that changed.
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    left: isFull ? 0 : _cursor * (_slotWidth + _slotGap),
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      width: isFull ? totalWidth : _slotWidth,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
