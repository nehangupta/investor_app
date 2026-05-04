// ============================================================
// FILE: lib/bloc/deal/deal_bloc.dart
// PURPOSE: Fetches deals from repository, then handles
//          search and filter logic entirely in memory.
//
// KEY IDEA: We always keep the FULL list (allDeals) and a
//           FILTERED list (filteredDeals) in the state.
//           When any filter changes, we re-apply ALL filters
//           to allDeals to get the new filteredDeals.
// ============================================================

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/deal_repository.dart';
import '../../models/deal_model.dart';

// ─── EVENTS ────────────────────────────────────────────────

abstract class DealEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// App loads → fetch deals from repository
class FetchDeals extends DealEvent {}

// User types in search bar
class SearchDeals extends DealEvent {
  final String query;
  SearchDeals(this.query);
  @override
  List<Object?> get props => [query];
}

// User picks a filter from the filter sheet
class FilterDeals extends DealEvent {
  final RiskLevel? riskLevel;
  final String? industry;
  final double? minROI;
  final double? maxROI;

  FilterDeals({this.riskLevel, this.industry, this.minROI, this.maxROI});

  @override
  List<Object?> get props => [riskLevel, industry, minROI, maxROI];
}

// User taps "Clear All" filters
class ClearFilters extends DealEvent {}

// ─── STATES ────────────────────────────────────────────────

abstract class DealState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DealInitial extends DealState {}
class DealLoading extends DealState {}
class DealError extends DealState {
  final String message;
  DealError(this.message);
  @override
  List<Object?> get props => [message];
}

// Main loaded state — holds both full list and filtered list
class DealLoaded extends DealState {
  final List<Deal> allDeals;        // never changes — full API result
  final List<Deal> filteredDeals;   // what UI actually shows

  // Current active filters (to restore when user opens filter sheet again)
  final String searchQuery;
  final RiskLevel? activeRisk;
  final String? activeIndustry;
  final double? activeMinROI;
  final double? activeMaxROI;

  DealLoaded({
    required this.allDeals,
    required this.filteredDeals,
    this.searchQuery     = '',
    this.activeRisk,
    this.activeIndustry,
    this.activeMinROI,
    this.activeMaxROI,
  });

  // True if ANY filter is currently active → shows filter badge
  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      activeRisk != null ||
      activeIndustry != null ||
      activeMinROI != null ||
      activeMaxROI != null;

  @override
  List<Object?> get props => [
    allDeals, filteredDeals, searchQuery,
    activeRisk, activeIndustry, activeMinROI, activeMaxROI,
  ];
}

// ─── BLOC ──────────────────────────────────────────────────

class DealBloc extends Bloc<DealEvent, DealState> {
  final DealRepository _repository;

  DealBloc(this._repository) : super(DealInitial()) {
    on<FetchDeals>(_onFetchDeals);
    on<SearchDeals>(_onSearchDeals);
    on<FilterDeals>(_onFilterDeals);
    on<ClearFilters>(_onClearFilters);
  }

  // ── Handler 1: Fetch all deals from repository ──────────
  Future<void> _onFetchDeals(FetchDeals event, Emitter<DealState> emit) async {
    emit(DealLoading());
    try {
      final deals = await _repository.fetchDeals(); // waits for mock delay
      // Initially: allDeals == filteredDeals (no filters yet)
      emit(DealLoaded(allDeals: deals, filteredDeals: deals));
    } catch (e) {
      emit(DealError('Could not load deals. Please try again.'));
    }
  }

  // ── Handler 2: Search typed → re-filter ─────────────────
  void _onSearchDeals(SearchDeals event, Emitter<DealState> emit) {
    if (state is! DealLoaded) return;
    final current = state as DealLoaded;

    // Apply search PLUS any existing filters
    final filtered = _applyAllFilters(
      current.allDeals,
      query:    event.query,
      risk:     current.activeRisk,
      industry: current.activeIndustry,
      minROI:   current.activeMinROI,
      maxROI:   current.activeMaxROI,
    );

    emit(DealLoaded(
      allDeals:       current.allDeals,
      filteredDeals:  filtered,
      searchQuery:    event.query,      // update query
      activeRisk:     current.activeRisk,
      activeIndustry: current.activeIndustry,
      activeMinROI:   current.activeMinROI,
      activeMaxROI:   current.activeMaxROI,
    ));
  }

  // ── Handler 3: Filter changed → re-filter ───────────────
  void _onFilterDeals(FilterDeals event, Emitter<DealState> emit) {
    if (state is! DealLoaded) return;
    final current = state as DealLoaded;

    // Apply new filters PLUS existing search query
    final filtered = _applyAllFilters(
      current.allDeals,
      query:    current.searchQuery,
      risk:     event.riskLevel,
      industry: event.industry,
      minROI:   event.minROI,
      maxROI:   event.maxROI,
    );

    emit(DealLoaded(
      allDeals:       current.allDeals,
      filteredDeals:  filtered,
      searchQuery:    current.searchQuery,
      activeRisk:     event.riskLevel,  // update filters
      activeIndustry: event.industry,
      activeMinROI:   event.minROI,
      activeMaxROI:   event.maxROI,
    ));
  }

  // ── Handler 4: Clear all filters ────────────────────────
  void _onClearFilters(ClearFilters event, Emitter<DealState> emit) {
    if (state is! DealLoaded) return;
    final current = state as DealLoaded;
    // Reset: show all deals, no active filters
    emit(DealLoaded(allDeals: current.allDeals, filteredDeals: current.allDeals));
  }

  // ── Core filtering logic ─────────────────────────────────
  // This is called every time ANY filter or search changes.
  // It applies ALL conditions together with AND logic.
  List<Deal> _applyAllFilters(
    List<Deal> deals, {
    String query     = '',
    RiskLevel? risk,
    String? industry,
    double? minROI,
    double? maxROI,
  }) {
    return deals.where((deal) {
      // Each condition: if filter is null/empty → treat as "no filter" (pass)
      final matchesSearch   = query.isEmpty || deal.companyName.toLowerCase().contains(query.toLowerCase());
      final matchesRisk     = risk == null || deal.riskLevel == risk;
      final matchesIndustry = industry == null || deal.industry == industry;
      final matchesMinROI   = minROI == null || deal.expectedROI >= minROI;
      final matchesMaxROI   = maxROI == null || deal.expectedROI <= maxROI;

      // Deal passes ONLY if ALL conditions are true
      return matchesSearch && matchesRisk && matchesIndustry && matchesMinROI && matchesMaxROI;
    }).toList();
  }
}
