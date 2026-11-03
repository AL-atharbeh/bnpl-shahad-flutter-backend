import 'package:flutter/material.dart';

import '../../core/l10n/language_service.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../dashboard/dashboard_page.dart';
import '../pos/pos_page.dart';
import '../products/products_page.dart';
import '../sales/sales_page.dart';
import '../settings/account_page.dart';

/// Five tabs under the customer app's floating bar. The portal's seven
/// sections map onto them: sales and transactions share a tab, and profits and
/// store settings live under the account tab.
class MerchantShell extends StatefulWidget {
  const MerchantShell({super.key});

  static MerchantShellState? of(BuildContext context) =>
      context.findAncestorStateOfType<MerchantShellState>();

  @override
  State<MerchantShell> createState() => MerchantShellState();
}

class MerchantShellState extends State<MerchantShell> {
  static const home = 0, pos = 1, products = 2, sales = 3, account = 4;

  int _index = home;

  /// Bumped when a sale completes, so tabs showing totals reload.
  final ValueNotifier<int> dataVersion = ValueNotifier(0);

  void goTo(int index) => setState(() => _index = index);

  void notifyDataChanged() => dataVersion.value++;

  @override
  void dispose() {
    dataVersion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: const [
              DashboardPage(),
              PosPage(),
              ProductsPage(),
              SalesPage(),
              AccountPage(),
            ],
          ),
          GlassBottomNav(
            currentIndex: _index,
            onTabChanged: goTo,
            items: [
              GlassNavItem(Icons.grid_view_rounded, context.tr('navHome')),
              GlassNavItem(Icons.point_of_sale_rounded, context.tr('navPos')),
              GlassNavItem(
                Icons.inventory_2_rounded,
                context.tr('navProducts'),
              ),
              GlassNavItem(Icons.receipt_long_rounded, context.tr('navSales')),
              GlassNavItem(Icons.person_rounded, context.tr('navAccount')),
            ],
          ),
        ],
      ),
    );
  }
}
