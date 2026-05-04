// ============================================================
// FILE: lib/screens/deal_list_screen.dart
// PURPOSE: Main screen after login.
//          Shows search bar, filter button, and list of deals.
//          Dispatches events to DealBloc and InterestBloc.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/deal/deal_bloc.dart';
import '../bloc/interest/interest_bloc.dart';
import '../models/deal_model.dart';
import '../utils/app_theme.dart';
import '../widgets/deal_card.dart';
import 'deal_detail_screen.dart';
import 'interests_screen.dart';

class DealListScreen extends StatefulWidget {
  const DealListScreen({super.key});
  @override
  State<DealListScreen> createState() => _DealListScreenState();
}

class _DealListScreenState extends State<DealListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch deals as soon as this screen loads
    context.read<DealBloc>().add(FetchDeals());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Opens the filter bottom sheet
  void _openFilterSheet(DealLoaded state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _FilterBottomSheet(
        currentState: state,
        onApply: (risk, industry, minROI, maxROI) {
          context.read<DealBloc>().add(
            FilterDeals(riskLevel: risk, industry: industry, minROI: minROI, maxROI: maxROI),
          );
        },
        onClear: () => context.read<DealBloc>().add(ClearFilters()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Deals'),
        actions: [
          // My Interests icon
          BlocBuilder<InterestBloc, InterestState>(
            builder: (context, interestState) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.star_rounded, color: AppColors.gold),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: context.read<InterestBloc>(),
                          child: const InterestsScreen(),
                        ),
                      ),
                    ),
                  ),
                  // Count badge
                  if (interestState.interestedDeals.isNotEmpty)
                    Positioned(
                      right: 6, top: 6,
                      child: Container(
                        width: 16, height: 16,
                        decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${interestState.interestedDeals.length}',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Logout menu
          PopupMenuButton<String>(
            color: AppColors.surface,
            onSelected: (val) {
              if (val == 'logout') context.read<AuthBloc>().add(LogoutRequested());
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(children: [
                  Icon(Icons.logout, color: AppColors.highRisk, size: 18),
                  SizedBox(width: 8),
                  Text('Logout', style: TextStyle(color: AppColors.textPrimary)),
                ]),
              ),
            ],
          ),
        ],
      ),

      body: BlocBuilder<DealBloc, DealState>(
        builder: (context, state) {

          // ── Loading state ─────────────────────────────
          if (state is DealLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.accent),
                  SizedBox(height: 16),
                  Text('Fetching investment deals...', style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }

          // ── Error state ───────────────────────────────
          if (state is DealError) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.highRisk),
                const SizedBox(height: 12),
                Text(state.message, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.read<DealBloc>().add(FetchDeals()),
                  child: const Text('Try Again'),
                ),
              ]),
            );
          }

          // ── Loaded state ──────────────────────────────
          if (state is DealLoaded) {
            return Column(
              children: [

                // ── Search + Filter bar ─────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      // Search field
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: AppColors.textPrimary),
                          onChanged: (q) => context.read<DealBloc>().add(SearchDeals(q)),
                          decoration: const InputDecoration(
                            hintText: 'Search companies...',
                            prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Filter button
                      GestureDetector(
                        onTap: () => _openFilterSheet(state),
                        child: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: state.hasActiveFilters
                                ? AppColors.accent.withOpacity(0.15)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: state.hasActiveFilters ? AppColors.accent : AppColors.divider,
                            ),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            color: state.hasActiveFilters ? AppColors.accent : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Active filter chips row ─────────────
                if (state.hasActiveFilters)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        if (state.activeRisk != null)
                          _FilterChip(
                            label: '${state.activeRisk!.label} Risk',
                            onRemove: () => context.read<DealBloc>().add(
                              FilterDeals(industry: state.activeIndustry, minROI: state.activeMinROI, maxROI: state.activeMaxROI),
                            ),
                          ),
                        if (state.activeIndustry != null)
                          _FilterChip(
                            label: state.activeIndustry!,
                            onRemove: () => context.read<DealBloc>().add(
                              FilterDeals(riskLevel: state.activeRisk, minROI: state.activeMinROI, maxROI: state.activeMaxROI),
                            ),
                          ),
                        if (state.activeMinROI != null || state.activeMaxROI != null)
                          _FilterChip(
                            label: 'ROI: ${state.activeMinROI?.toStringAsFixed(0) ?? '0'}–${state.activeMaxROI?.toStringAsFixed(0) ?? '50'}%',
                            onRemove: () => context.read<DealBloc>().add(
                              FilterDeals(riskLevel: state.activeRisk, industry: state.activeIndustry),
                            ),
                          ),
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            context.read<DealBloc>().add(ClearFilters());
                          },
                          child: const Text('Clear all', style: TextStyle(color: AppColors.highRisk, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                // ── Results count ───────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${state.filteredDeals.length} deal${state.filteredDeals.length != 1 ? 's' : ''} found',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ),

                // ── Deal list ───────────────────────────
                Expanded(
                  child: state.filteredDeals.isEmpty
                      // Empty state
                      ? const Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.search_off_rounded, size: 50, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('No deals match your search', style: TextStyle(color: AppColors.textSecondary)),
                          ]),
                        )
                      // List
                      : BlocBuilder<InterestBloc, InterestState>(
                          builder: (context, interestState) {
                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 4, bottom: 24),
                              itemCount: state.filteredDeals.length,
                              itemBuilder: (_, i) {
                                final deal = state.filteredDeals[i];
                                return DealCard(
                                  deal: deal,
                                  isInterested: interestState.isInterested(deal.id),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider.value(value: context.read<InterestBloc>()),
                                        ],
                                        child: DealDetailScreen(deal: deal),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Active filter chip widget ───────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _FilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

// ── Filter bottom sheet ─────────────────────────────────────
class _FilterBottomSheet extends StatefulWidget {
  final DealLoaded currentState;
  final Function(RiskLevel?, String?, double?, double?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    required this.currentState,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  RiskLevel? _selectedRisk;
  String? _selectedIndustry;
  RangeValues _roiRange = const RangeValues(0, 50);

  static const _industries = ['CleanEnergy', 'FinTech', 'HealthTech', 'AgriTech', 'Logistics', 'EdTech'];

  @override
  void initState() {
    super.initState();
    // Pre-fill with current active filters
    _selectedRisk     = widget.currentState.activeRisk;
    _selectedIndustry = widget.currentState.activeIndustry;
    _roiRange = RangeValues(
      widget.currentState.activeMinROI ?? 0,
      widget.currentState.activeMaxROI ?? 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Header
          Row(children: [
            const Text('Filters', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            const Spacer(),
            TextButton(
              onPressed: () { widget.onClear(); Navigator.pop(context); },
              child: const Text('Clear All', style: TextStyle(color: AppColors.highRisk)),
            ),
          ]),

          const SizedBox(height: 16),

          // Risk Level
          const Text('Risk Level', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          Row(
            children: RiskLevel.values.map((r) {
              final isSelected = _selectedRisk == r;
              final color = r == RiskLevel.low ? AppColors.lowRisk : r == RiskLevel.medium ? AppColors.mediumRisk : AppColors.highRisk;
              return GestureDetector(
                onTap: () => setState(() => _selectedRisk = isSelected ? null : r),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : AppColors.chipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? color : Colors.transparent),
                  ),
                  child: Text(r.label,
                      style: TextStyle(color: isSelected ? color : AppColors.textSecondary,
                          fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Industry
          const Text('Industry', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _industries.map((ind) {
              final isSelected = _selectedIndustry == ind;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndustry = isSelected ? null : ind),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent.withOpacity(0.12) : AppColors.chipBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.accent : Colors.transparent),
                  ),
                  child: Text(ind,
                      style: TextStyle(color: isSelected ? AppColors.accent : AppColors.textSecondary,
                          fontSize: 12, fontWeight: FontWeight.w500)),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ROI Range slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ROI Range', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              Text(
                '${_roiRange.start.toStringAsFixed(0)}% – ${_roiRange.end.toStringAsFixed(0)}%',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.chipBg,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.15),
            ),
            child: RangeSlider(
              values: _roiRange,
              min: 0, max: 50, divisions: 10,
              onChanged: (v) => setState(() => _roiRange = v),
            ),
          ),

          const SizedBox(height: 20),

          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  _selectedRisk,
                  _selectedIndustry,
                  _roiRange.start > 0   ? _roiRange.start : null,
                  _roiRange.end   < 50  ? _roiRange.end   : null,
                );
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),

        ],
      ),
    );
  }
}
