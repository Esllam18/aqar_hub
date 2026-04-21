export 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/dashboard/owner_kpi_row.dart';

import 'package:aqar_hub/features/owner/home/presentation/widgets/owner_home/owner_stats_cards.dart';
import 'package:flutter/material.dart';

// This widget is no longer used directly — OwnerHomeView v2 uses OwnerKpiRow.
// Kept to avoid breaking any other screen that might reference it.
class OwnerHomeHeader extends StatelessWidget {
  final int total;
  final int sale;
  final int rented;
  final int alerts;

  const OwnerHomeHeader({
    super.key,
    required this.total,
    required this.sale,
    required this.rented,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return OwnerStatsCards(
      total: total,
      sale: sale,
      rented: rented,
      alerts: alerts,
    );
  }
}
