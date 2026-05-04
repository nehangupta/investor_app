// ============================================================
// FILE: lib/screens/deal_detail_screen.dart
// PURPOSE: Full detail view of a single deal.
//          Shows: overview, financials, ROI chart, risk info.
//          Bottom button: "I'm Interested" / "Remove Interest"
// ============================================================


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../bloc/interest/interest_bloc.dart';
import '../models/deal_model.dart';
import '../utils/app_theme.dart';

class DealDetailScreen extends StatelessWidget {
  final Deal deal;
  const DealDetailScreen({super.key, required this.deal});

  Color get _riskColor {
    switch (deal.riskLevel) {
      case RiskLevel.low:
        return AppColors.lowRisk;
      case RiskLevel.medium:
        return AppColors.mediumRisk;
      case RiskLevel.high:
        return AppColors.highRisk;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // 🔹 HEADER
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D2E4F), Color(0xFF071A2C)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deal.companyName,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _HeaderTag(deal.industry),
                        _HeaderTag('${deal.riskLevel.label} Risk',
                            color: _riskColor),
                        _HeaderTag(
                          deal.status.label,
                          color: deal.status == DealStatus.open
                              ? AppColors.openStatus
                              : AppColors.closedStatus,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 🔹 CONTENT
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // 🔹 KEY STATS
                  Row(
                    children: [
                      _KeyStatCard(
                        icon: Icons.account_balance_wallet,
                        label: 'Investment Required',
                        value: deal.formattedInvestment,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 12),
                      _KeyStatCard(
                        icon: Icons.trending_up,
                        label: 'Expected ROI',
                        value: '${deal.expectedROI}%',
                        color: AppColors.lowRisk,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('Company Overview'),
                  const SizedBox(height: 8),
                  Text(
                    deal.companyOverview,
                    style: const TextStyle(
                        color: AppColors.textSecondary, height: 1.6),
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('Financial Highlights'),
                  const SizedBox(height: 12),

                  // 🔹 FIXED GRID
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deal.financialHighlights.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.6, // ✅ FIXED
                    ),
                    itemBuilder: (_, i) {
                      final h = deal.financialHighlights[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border:
                          Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              h.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              h.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('ROI Projection'),
                  const SizedBox(height: 12),

                  // 🔹 CHART
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: LineChart(
                      LineChartData(
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                              sideTitles:
                              SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles:
                              SideTitles(showTitles: false)),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: deal.roiProjections
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                e.key.toDouble(),
                                e.value.value))
                                .toList(),
                            isCurved: true,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  _SectionTitle('Risk Analysis'),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _riskColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      deal.riskExplanation,
                      style: const TextStyle(
                          color: AppColors.textSecondary),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 BOTTOM BUTTON
      bottomNavigationBar:
      BlocBuilder<InterestBloc, InterestState>(
        builder: (context, state) {
          final isInterested = state.isInterested(deal.id);

          return Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<InterestBloc>()
                    .add(AddInterest(deal));
              },
              child: Text(isInterested
                  ? "Already Interested"
                  : "I'm Interested"),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// 🔹 HELPERS
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context).textTheme.titleMedium);
  }
}

class _HeaderTag extends StatelessWidget {
  final String label;
  final Color? color;
  const _HeaderTag(this.label, {this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
        (color ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: color ?? Colors.grey)),
    );
  }
}

class _KeyStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KeyStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded( // ✅ FIX
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10)),
                  Text(value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}