// ============================================================
// FILE: lib/data/deal_repository.dart
// PURPOSE: Acts as the "API layer". In a real app this would
//          call a REST API. Here we use hardcoded JSON with a
//          simulated network delay to mimic real behavior.
// ============================================================

import 'dart:convert';
import '../models/deal_model.dart';

// The mock JSON — pretend this comes from a server
const String _mockDealsJson = '''
[
  {
    "id": "1",
    "companyName": "GreenTech Ventures",
    "industry": "CleanEnergy",
    "investmentRequired": 5000000,
    "expectedROI": 28.5,
    "riskLevel": "Low",
    "status": "Open",
    "companyOverview": "GreenTech Ventures is a leading renewable energy startup focused on solar micro-grid solutions for rural India. Founded in 2019, it has deployed 120+ installations across 8 states with government-backed contracts.",
    "riskExplanation": "Low risk due to government subsidies, long-term power purchase agreements (PPAs), and stable recurring revenue. Primary risk is regulatory changes in solar policy.",
    "financialHighlights": [
      {"label": "Revenue (FY23)", "value": "₹3.2 Cr"},
      {"label": "EBITDA Margin",  "value": "22%"},
      {"label": "Debt-to-Equity", "value": "0.3x"},
      {"label": "Valuation",      "value": "₹48 Cr"}
    ],
    "roiProjections": [
      {"year": "Y1", "value": 8.0},
      {"year": "Y2", "value": 14.5},
      {"year": "Y3", "value": 20.0},
      {"year": "Y4", "value": 25.0},
      {"year": "Y5", "value": 28.5}
    ]
  },
  {
    "id": "2",
    "companyName": "FinFlow AI",
    "industry": "FinTech",
    "investmentRequired": 12000000,
    "expectedROI": 42.0,
    "riskLevel": "High",
    "status": "Open",
    "companyOverview": "FinFlow AI builds ML-powered credit scoring for the unbanked population. Partnered with 3 NBFCs and serving 200K+ users across Tier 2 and 3 cities.",
    "riskExplanation": "High risk due to regulatory uncertainty in digital lending, dependency on NBFC partnerships, and high customer acquisition costs in target segments.",
    "financialHighlights": [
      {"label": "ARR",        "value": "₹7.8 Cr"},
      {"label": "MoM Growth", "value": "18%"},
      {"label": "Burn Rate",  "value": "₹60L/mo"},
      {"label": "Runway",     "value": "14 months"}
    ],
    "roiProjections": [
      {"year": "Y1", "value": 5.0},
      {"year": "Y2", "value": 18.0},
      {"year": "Y3", "value": 30.0},
      {"year": "Y4", "value": 38.0},
      {"year": "Y5", "value": 42.0}
    ]
  },
  {
    "id": "3",
    "companyName": "MediLink Health",
    "industry": "HealthTech",
    "investmentRequired": 8000000,
    "expectedROI": 33.0,
    "riskLevel": "Medium",
    "status": "Open",
    "companyOverview": "MediLink connects patients with specialist doctors via AI-assisted triage. Operating in 5 metro cities with 1,200 empanelled doctors and 80,000 monthly consultations.",
    "riskExplanation": "Medium risk from competition with larger telemedicine platforms, dependency on doctor retention, and evolving telehealth regulations by NMC.",
    "financialHighlights": [
      {"label": "Revenue (FY23)", "value": "₹5.1 Cr"},
      {"label": "Gross Margin",   "value": "68%"},
      {"label": "Active Users",   "value": "2.3L"},
      {"label": "Valuation",      "value": "₹95 Cr"}
    ],
    "roiProjections": [
      {"year": "Y1", "value": 10.0},
      {"year": "Y2", "value": 18.0},
      {"year": "Y3", "value": 25.0},
      {"year": "Y4", "value": 30.0},
      {"year": "Y5", "value": 33.0}
    ]
  },
  {
    "id": "4",
    "companyName": "AgroSmart Solutions",
    "industry": "AgriTech",
    "investmentRequired": 3500000,
    "expectedROI": 22.0,
    "riskLevel": "Low",
    "status": "Open",
    "companyOverview": "AgroSmart provides IoT-based soil and weather monitoring to 15,000+ farmers. Its subscription model delivers real-time crop advisory, reducing losses by up to 35%.",
    "riskExplanation": "Low risk supported by PMKSY government partnerships, subsidized hardware, and high farmer retention. Weather dependency and rural connectivity are manageable risks.",
    "financialHighlights": [
      {"label": "Subscribers", "value": "15,200"},
      {"label": "ARPU",        "value": "₹1,800/yr"},
      {"label": "Churn Rate",  "value": "4.2%"},
      {"label": "Valuation",   "value": "₹38 Cr"}
    ],
    "roiProjections": [
      {"year": "Y1", "value": 6.0},
      {"year": "Y2", "value": 12.0},
      {"year": "Y3", "value": 16.0},
      {"year": "Y4", "value": 20.0},
      {"year": "Y5", "value": 22.0}
    ]
  },
  {
    "id": "5",
    "companyName": "SpaceLogix",
    "industry": "Logistics",
    "investmentRequired": 20000000,
    "expectedROI": 38.0,
    "riskLevel": "High",
    "status": "Closed",
    "companyOverview": "SpaceLogix is building India's first satellite-based cold-chain tracking for pharmaceutical logistics. In stealth beta with 2 major pharma companies.",
    "riskExplanation": "High risk due to pre-revenue stage, dependence on ISRO spectrum allocation, high capex for satellite uplinks, and long enterprise sales cycles.",
    "financialHighlights": [
      {"label": "Pilot Revenue",     "value": "₹1.2 Cr"},
      {"label": "Contract Pipeline", "value": "₹22 Cr"},
      {"label": "IP Filed",          "value": "7 Patents"},
      {"label": "Valuation",         "value": "₹180 Cr"}
    ],
    "roiProjections": [
      {"year": "Y1", "value": 0.0},
      {"year": "Y2", "value": 12.0},
      {"year": "Y3", "value": 24.0},
      {"year": "Y4", "value": 33.0},
      {"year": "Y5", "value": 38.0}
    ]
  },
  {
    "id": "6",
    "companyName": "EduVerse",
    "industry": "EdTech",
    "investmentRequired": 6000000,
    "expectedROI": 30.0,
    "riskLevel": "Medium",
    "status": "Open",
    "companyOverview": "EduVerse offers gamified STEM learning for K-12 students with AR-based lab simulations. Currently in 240 schools across Maharashtra and Gujarat with a B2B SaaS model.",
    "riskExplanation": "Medium risk from school budget cycles, competition from well-funded EdTech players, and revenue tied to academic calendars.",
    "financialHighlights": [
      {"label": "School Contracts", "value": "240"},
      {"label": "Avg Contract",     "value": "₹2.4L/yr"},
      {"label": "ARR",              "value": "₹5.76 Cr"},
      {"label": "Valuation",        "value": "₹70 Cr"}
    ],
    "roiProjections": [
      {"year": "Y1", "value": 9.0},
      {"year": "Y2", "value": 16.0},
      {"year": "Y3", "value": 22.0},
      {"year": "Y4", "value": 27.0},
      {"year": "Y5", "value": 30.0}
    ]
  }
]
''';

// The repository class — this is what BLoC calls to get data
class DealRepository {
  Future<List<Deal>> fetchDeals() async {
    // Simulate network delay (like a real API taking time)
    await Future.delayed(const Duration(milliseconds: 1200));

    // Parse JSON string → List of Deal objects
    final List<dynamic> jsonList = jsonDecode(_mockDealsJson);
    return jsonList.map((json) => Deal.fromJson(json)).toList();
  }
}
