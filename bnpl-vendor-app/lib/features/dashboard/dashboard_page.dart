import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/language_service.dart';
import '../../core/session/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../../core/widgets/ui.dart';
import '../finance/finance_page.dart';
import '../shell/merchant_shell.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _performance = const [];
  bool _loading = true;
  Object? _error;
  bool _requestingSettlement = false;
  ValueNotifier<int>? _dataVersion;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dataVersion ??= MerchantShell.of(context)?.dataVersion
      ?..addListener(_load);
  }

  @override
  void dispose() {
    _dataVersion?.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final session = context.read<SessionService>();
    setState(() => _error = null);
    try {
      final results = await Future.wait([
        session.api.dashboardStats(session.storeId),
        session.api.performance(session.storeId),
      ]);
      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _performance = results[1] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _requestSettlement() async {
    final confirmed = await confirmDialog(
      context,
      message: context.trNow('confirmSettlement'),
      confirmLabel: context.trNow('send'),
    );
    if (!confirmed || !mounted) return;

    setState(() => _requestingSettlement = true);
    final session = context.read<SessionService>();
    try {
      await session.api.requestSettlement(session.storeId, session.name);
      if (mounted) showToast(context, context.trNow('settlementRequested'));
    } catch (e) {
      if (mounted) {
        showToast(
          context,
          errorMessage(context, e, fallbackKey: 'settlementFailed'),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _requestingSettlement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionService>();
    final currency = context.tr('currency');
    final shell = MerchantShell.of(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.only(bottom: GlassBottomNav.clearance(context)),
          children: [
            _Header(name: session.name),
            if (_loading)
              const LoadingState()
            else if (_error != null && _stats == null)
              ErrorState(
                message: errorMessage(context, _error!),
                onRetry: _load,
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _HeroCard(
                  label: context.tr('totalSales'),
                  value: money(
                    toDouble(_stats?['totalFinancedQuarter']),
                    currency,
                  ),
                  detail: context.tr('basedOnInstallments'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        icon: Icons.payments_rounded,
                        label: context.tr('totalCollections'),
                        value: money(
                          toDouble(_stats?['totalCollected']),
                          currency,
                        ),
                        detail: context.tr('completedPayments'),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        icon: Icons.account_balance_rounded,
                        label: context.tr('platformCommission'),
                        value: money(
                          toDouble(_stats?['totalCommission']),
                          currency,
                        ),
                        detail: context.tr('serviceFees'),
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: _RiskTile(ratio: toDouble(_stats?['riskIndicator'])),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: SectionTitle(context.tr('quickActions')),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _ActionTile(
                      icon: Icons.point_of_sale_rounded,
                      title: context.tr('newSale'),
                      detail: context.tr('newSaleDetail'),
                      onTap: () => shell?.goTo(MerchantShellState.pos),
                      highlighted: true,
                    ),
                    _ActionTile(
                      icon: Icons.sell_rounded,
                      title: context.tr('updatePrices'),
                      detail: context.tr('updatePricesDetail'),
                      onTap: () => shell?.goTo(MerchantShellState.products),
                    ),
                    _ActionTile(
                      icon: Icons.request_quote_rounded,
                      title: context.tr('requestSettlement'),
                      detail: context.tr('requestSettlementDetail'),
                      onTap: _requestingSettlement ? null : _requestSettlement,
                      busy: _requestingSettlement,
                    ),
                    _ActionTile(
                      icon: Icons.trending_up_rounded,
                      title: context.tr('viewProfits'),
                      detail: context.tr('viewProfitsDetail'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FinancePage()),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                child: SectionTitle(
                  context.tr('salesGrowth'),
                  subtitle: context.tr('last6Months'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionCard(
                  padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
                  child: SizedBox(
                    height: 210,
                    child: _SalesChart(points: _performance),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.green50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: AppColors.success,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.tr('accountActiveMsg'),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final initials = name.trim().isEmpty
        ? '؟'
        : name.trim().characters.take(2).toString().toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.tr('welcome')}، $name',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.tr('performanceSummary'),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.green50,
              shape: BoxShape.circle,
            ),
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PositionedDirectional(
            end: -10,
            top: -10,
            child: Icon(
              Icons.trending_up_rounded,
              size: 90,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detail,
                style: TextStyle(
                  fontSize: 12.5,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.detail,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.heading,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class _RiskTile extends StatelessWidget {
  const _RiskTile({required this.ratio});

  final double ratio;

  @override
  Widget build(BuildContext context) {
    final color = ratio >= 10
        ? AppColors.error
        : (ratio >= 5 ? AppColors.warning : AppColors.success);

    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.shield_outlined, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        context.tr('riskLevel'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.heading,
                        ),
                      ),
                    ),
                    Text(
                      '${ratio.toStringAsFixed(1)} %',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (ratio / 100).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: AppColors.hairline,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('riskRatio'),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    this.highlighted = false,
    this.busy = false,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback? onTap;
  final bool highlighted;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? Colors.white : AppColors.heading;

    return SectionCard(
      onTap: onTap,
      color: highlighted ? AppColors.primary : Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          busy
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.accent,
                  ),
                )
              : Icon(
                  icon,
                  size: 26,
                  color: highlighted ? Colors.white : AppColors.accent,
                ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            detail,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: highlighted
                  ? Colors.white.withValues(alpha: 0.75)
                  : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.points});

  final List<Map<String, dynamic>> points;

  @override
  Widget build(BuildContext context) {
    final values = points.map((p) => toDouble(p['purchases'])).toList();
    if (values.isEmpty || values.every((v) => v == 0)) {
      return Center(
        child: Text(
          context.tr('noChartData'),
          style: const TextStyle(color: AppColors.textHint),
        ),
      );
    }

    final maxY = values.reduce((a, b) => a > b ? a : b) * 1.2;
    final spots = [
      for (var i = 0; i < values.length; i++) FlSpot(i.toDouble(), values[i]),
    ];

    // Months read in time order from the reading direction's start.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (_) =>
                const FlLine(color: AppColors.hairline, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) => Text(
                  _compact(value),
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.textHint,
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 28,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= points.length || value != i.toDouble()) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${points[i]['month'] ?? ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.heading,
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    money(s.y, context.trNow('currency')),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              color: AppColors.primaryLight,
              barWidth: 3,
              dotData: FlDotData(
                getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                  radius: 3.5,
                  color: Colors.white,
                  strokeWidth: 2.5,
                  strokeColor: AppColors.primaryLight,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryLight.withValues(alpha: 0.28),
                    AppColors.primaryLight.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _compact(double v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(v >= 10000 ? 0 : 1)}K';
    return v.toStringAsFixed(0);
  }
}
