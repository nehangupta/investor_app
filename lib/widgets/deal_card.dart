// ============================================================
// FILE: lib/widgets/deal_card.dart
// PURPOSE: Reusable card shown in the deal list.
//          Takes a Deal object + callbacks as parameters.
//          Has ZERO business logic — purely displays data.
// ============================================================

import 'package:flutter/material.dart';
import '../models/deal_model.dart';
import '../utils/app_theme.dart';

class DealCard extends StatelessWidget {
  final Deal deal;
  final bool isInterested; // whether star badge shows
  final VoidCallback onTap;

  const DealCard({
    super.key,
    required this.deal,
    required this.isInterested,
    required this.onTap,
  });

  // Returns the right color based on risk level
  Color get _riskColor {
    switch (deal.riskLevel) {
      case RiskLevel.low:    return AppColors.lowRisk;
      case RiskLevel.medium: return AppColors.mediumRisk;
      case RiskLevel.high:   return AppColors.highRisk;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          // Highlight card border if user has expressed interest
          border: Border.all(
            color: isInterested
                ? AppColors.accent.withOpacity(0.5)
                : AppColors.divider,
            width: isInterested ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Row 1: Company name + Interested badge ───
              Row(
                children: [
                  Expanded(
                    child: Text(deal.companyName,
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  if (isInterested) _InterestedBadge(),
                ],
              ),

              const SizedBox(height: 10),

              // ── Row 2: Tags (Industry, Risk, Status) ─────
              Row(
                children: [
                  _Tag(deal.industry, icon: Icons.business_rounded, color: AppColors.accent),
                  const SizedBox(width: 8),
                  _RiskTag(deal.riskLevel, _riskColor),
                  const Spacer(),
                  _StatusTag(deal.status),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 14),

              // ── Row 3: Investment amount + ROI ───────────
              Row(
                children: [
                  _StatItem(
                    icon: Icons.account_balance_wallet_rounded,
                    label: 'Investment',
                    value: deal.formattedInvestment,
                  ),
                  _StatItem(
                    icon: Icons.trending_up_rounded,
                    label: 'Expected ROI',
                    value: '${deal.expectedROI}%',
                    valueColor: AppColors.lowRisk,
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }
}

// ── Small reusable sub-widgets ──────────────────────────────

class _InterestedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: AppColors.accent),
          SizedBox(width: 4),
          Text('Interested',
              style: TextStyle(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _Tag(this.label, {required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _RiskTag extends StatelessWidget {
  final RiskLevel level;
  final Color color;
  const _RiskTag(this.level, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text('${level.label} Risk',
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final DealStatus status;
  const _StatusTag(this.status);

  @override
  Widget build(BuildContext context) {
    final isOpen = status == DealStatus.open;
    final color = isOpen ? AppColors.openStatus : AppColors.closedStatus;
    return Row(
      children: [
        Container(
          width: 7, height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(status.label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.icon, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: TextStyle(
                fontSize: 15,
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ],
      ),
    );
  }
}
