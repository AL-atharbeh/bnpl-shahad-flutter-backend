import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared frame for the onboarding screens.
///
/// Registration runs over five screens, so each one shows where the person is
/// and lets them go back. Keeping the frame in one place also keeps the spacing
/// and type scale identical from screen to screen, which is most of what makes
/// a flow feel finished.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    required this.children,
    this.action,
    this.footer,
    this.onBack,
    this.totalSteps = 5,
  });

  /// 1-based position in the flow.
  final int step;
  final int totalSteps;
  final String title;
  final String subtitle;

  /// Body content, laid out in a column.
  final List<Widget> children;

  /// Pinned above the bottom edge, clear of the keyboard.
  final Widget? action;

  /// Small note under the action, usually a reassurance.
  final Widget? footer;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final canGoBack = onBack != null || Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              step: step,
              totalSteps: totalSteps,
              onBack: canGoBack ? (onBack ?? () => Navigator.of(context).pop()) : null,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 26,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...children,
                  ],
                ),
              ),
            ),
            if (action != null)
              Padding(
                // Lifts the action above the keyboard when one is open.
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 8,
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    action!,
                    if (footer != null) ...[
                      const SizedBox(height: 16),
                      footer!,
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.step,
    required this.totalSteps,
    required this.onBack,
  });

  final int step;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final isArabic = Directionality.of(context) == TextDirection.rtl;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: onBack == null
                    ? null
                    : IconButton(
                        onPressed: onBack,
                        // Mirrors with the layout direction, so it always points
                        // back rather than in a fixed direction.
                        icon: const Icon(Icons.arrow_back_rounded, size: 22),
                        color: AppColors.textSecondary,
                        splashRadius: 22,
                        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                      ),
              ),
              Expanded(
                child: Center(
                  // The wordmark carries wide padding of its own, so at header
                  // size it reads as a smudge. The step count is both legible
                  // and more use to someone partway through five screens.
                  child: Text(
                    isArabic
                        ? 'الخطوة $step من $totalSteps'
                        : 'Step $step of $totalSteps',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 12),
          _StepBar(step: step, totalSteps: totalSteps),
        ],
      ),
    );
  }
}

/// One segment per screen, so the remaining work is visible at a glance rather
/// than implied by a percentage.
class _StepBar extends StatelessWidget {
  const _StepBar({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final done = index < step;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 6),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              height: 4,
              decoration: BoxDecoration(
                color: done ? AppColors.primary : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// The single primary action each screen ends with.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textHint,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

/// Reassurance line shown under the action.
class AuthFooterNote extends StatelessWidget {
  const AuthFooterNote({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon ?? Icons.lock_outline_rounded, size: 15, color: AppColors.textHint),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.textHint,
            ),
          ),
        ),
      ],
    );
  }
}
