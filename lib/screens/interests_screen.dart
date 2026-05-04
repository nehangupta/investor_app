// ============================================================
// FILE: lib/screens/interests_screen.dart
// PURPOSE: Shows all deals the user expressed interest in.
//          Supports swipe-to-remove via Dismissible widget.
// ============================================================



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/interest/interest_bloc.dart';
import '../models/deal_model.dart';
import '../utils/app_theme.dart';
import '../widgets/deal_card.dart';
import 'deal_detail_screen.dart';

class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key});

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  // Local copy of the deals list — drives the ListView directly.
  // Updated immediately on swipe so Dismissible animates correctly,
  // without waiting for the bloc → state → BlocBuilder cycle.
  late List<Deal> _localDeals;

  @override
  void initState() {
    super.initState();
    // Seed local list from current bloc state
    _localDeals = List<Deal>.from(
      context.read<InterestBloc>().state.interestedDeals,
    );
  }

  void _removeDeal(String dealId) {
    // 1. Update local list immediately → Dismissible slides out cleanly
    setState(() {
      _localDeals.removeWhere((d) => d.id == dealId);
    });
    // 2. Dispatch to bloc → persists to SharedPreferences
    context.read<InterestBloc>().add(RemoveInterest(dealId));
  }

  @override
  Widget build(BuildContext context) {
    // Listen for external changes to the bloc (e.g. interest added from
    // DealDetailScreen while this screen is open) and sync local list.
    return BlocListener<InterestBloc, InterestState>(
      listener: (context, state) {
        setState(() {
          _localDeals = List<Deal>.from(state.interestedDeals);
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('My Interests')),
        body: _localDeals.isEmpty
            ? _buildEmptyState()
            : _buildList(),
      ),
    );
  }

  // ── Empty state ─────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_border_rounded,
              size: 42,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No interests yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap "I\'m Interested" on any deal\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.6),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Browse Deals'),
          ),
        ],
      ),
    );
  }

  // ── List of saved deals ──────────────────────────────────
  Widget _buildList() {
    return Column(
      children: [
        // Count header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Row(children: [
            const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
            const SizedBox(width: 6),
            Text(
              '${_localDeals.length} saved deal${_localDeals.length != 1 ? 's' : ''}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            const Text(
              '← Swipe to remove',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
          ]),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 24),
            itemCount: _localDeals.length,
            itemBuilder: (_, i) {
              final deal = _localDeals[i];

              return Dismissible(
                // ValueKey ensures Flutter tracks each item by deal ID
                key: ValueKey(deal.id),
                direction: DismissDirection.endToStart,
                // confirmDismiss lets animation fully complete first
                confirmDismiss: (_) async => true,
                onDismissed: (_) => _removeDeal(deal.id),
                // Required placeholder when secondaryBackground is set
                background: const SizedBox.shrink(),
                // Shown during endToStart (right-to-left) swipe
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.highRisk.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: AppColors.highRisk,
                        size: 26,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Remove',
                        style: TextStyle(
                          color: AppColors.highRisk,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                child: DealCard(
                  deal: deal,
                  isInterested: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<InterestBloc>(),
                        child: DealDetailScreen(deal: deal),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
