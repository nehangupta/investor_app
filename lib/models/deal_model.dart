// ============================================================
// FILE: lib/models/deal_model.dart
// PURPOSE: Defines what a "Deal" looks like — all its fields.
//          This is a pure data class with zero UI or logic.
// ============================================================

// ---------- ENUMS ----------
// Enums are used instead of plain strings to avoid typos.

enum RiskLevel {
  low,
  medium,
  high;

  // Converts a raw string like "Low" → RiskLevel.low
  static RiskLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':    return RiskLevel.low;
      case 'medium': return RiskLevel.medium;
      case 'high':   return RiskLevel.high;
      default:       return RiskLevel.medium;
    }
  }

  // Used to display in UI
  String get label {
    switch (this) {
      case RiskLevel.low:    return 'Low';
      case RiskLevel.medium: return 'Medium';
      case RiskLevel.high:   return 'High';
    }
  }
}

enum DealStatus {
  open,
  closed;

  static DealStatus fromString(String value) {
    return value.toLowerCase() == 'open' ? DealStatus.open : DealStatus.closed;
  }

  String get label => this == DealStatus.open ? 'Open' : 'Closed';
}

// ---------- SUPPORTING MODELS ----------

// One row in the financial highlights grid (e.g. "Revenue: ₹3.2 Cr")
class FinancialHighlight {
  final String label;
  final String value;

  const FinancialHighlight({required this.label, required this.value});

  // Converts JSON map → FinancialHighlight object
  factory FinancialHighlight.fromJson(Map<String, dynamic> json) {
    return FinancialHighlight(label: json['label'], value: json['value']);
  }
}

// One point on the ROI chart (e.g. Year 3 → 20%)
class ROIProjection {
  final String year;
  final double value;

  const ROIProjection({required this.year, required this.value});

  factory ROIProjection.fromJson(Map<String, dynamic> json) {
    return ROIProjection(
      year: json['year'],
      value: (json['value'] as num).toDouble(),
    );
  }
}

// ---------- MAIN DEAL MODEL ----------

class Deal {
  final String id;
  final String companyName;
  final String industry;
  final double investmentRequired; // in INR (e.g. 5000000 = ₹50L)
  final double expectedROI;        // percentage (e.g. 28.5 = 28.5%)
  final RiskLevel riskLevel;
  final DealStatus status;
  final String companyOverview;
  final String riskExplanation;
  final List<FinancialHighlight> financialHighlights;
  final List<ROIProjection> roiProjections;

  const Deal({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.investmentRequired,
    required this.expectedROI,
    required this.riskLevel,
    required this.status,
    required this.companyOverview,
    required this.riskExplanation,
    required this.financialHighlights,
    required this.roiProjections,
  });

  // Main constructor — converts JSON map → Deal object
  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id:                  json['id'],
      companyName:         json['companyName'],
      industry:            json['industry'],
      investmentRequired:  (json['investmentRequired'] as num).toDouble(),
      expectedROI:         (json['expectedROI'] as num).toDouble(),
      riskLevel:           RiskLevel.fromString(json['riskLevel']),
      status:              DealStatus.fromString(json['status']),
      companyOverview:     json['companyOverview'],
      riskExplanation:     json['riskExplanation'],
      financialHighlights: (json['financialHighlights'] as List)
                               .map((e) => FinancialHighlight.fromJson(e))
                               .toList(),
      roiProjections:      (json['roiProjections'] as List)
                               .map((e) => ROIProjection.fromJson(e))
                               .toList(),
    );
  }

  // Helper: formats raw number → "₹50 L" or "₹1.2 Cr"
  String get formattedInvestment {
    if (investmentRequired >= 10000000) {
      return '₹${(investmentRequired / 10000000).toStringAsFixed(1)} Cr';
    }
    return '₹${(investmentRequired / 100000).toStringAsFixed(0)} L';
  }
}
