# InvestNow — Flutter Investor Deal Management App

> **Assignment:** Mini Investor Deal Management App  
> **Company:** Micro Integrated Semiconductor Systems Pvt Ltd  
> **Demo Login:** `investor@demo.com` / `Demo@1234`

---

## 📱 App Screens

| Screen | Description |
|--------|-------------|
| Login | Email/password auth with session persistence |
| Deal List | Searchable, filterable list of investment deals |
| Deal Detail | Overview, financials, ROI chart, risk analysis |
| My Interests | All saved deals with swipe-to-remove |

---

## 🏗️ Architecture — Clean Architecture with BLoC

```
lib/
├── main.dart                        ← Entry point, MultiBlocProvider, AppRouter
│
├── models/
│   └── deal_model.dart              ← Deal, RiskLevel, DealStatus, FinancialHighlight, ROIProjection
│
├── data/
│   └── deal_repository.dart         ← Mock JSON data + simulated API delay
│
├── bloc/
│   ├── auth/
│   │   └── auth_bloc.dart           ← Login, Logout, Session check
│   ├── deal/
│   │   └── deal_bloc.dart           ← Fetch, Search, Filter, ClearFilters
│   └── interest/
│       └── interest_bloc.dart       ← Add/Remove interests, SharedPreferences
│
├── screens/
│   ├── login_screen.dart
│   ├── deal_list_screen.dart        ← Search bar + Filter sheet + ListView
│   ├── deal_detail_screen.dart      ← Chart + Financials + Express Interest
│   └── interests_screen.dart        ← Saved deals + Swipe to remove
│
├── widgets/
│   └── deal_card.dart               ← Reusable card (used in 2 screens)
│
└── utils/
    └── app_theme.dart               ← AppColors + AppTheme (dark fintech UI)
```

---

## 🔄 BLoC Flow

```
UI dispatches Event  →  BLoC processes  →  BLoC emits State  →  UI rebuilds
```

### AuthBloc
```
AppStarted      → checks SharedPreferences → AuthAuthenticated or AuthUnauthenticated
LoginRequested  → validates mock credentials → AuthAuthenticated or AuthError
LogoutRequested → clears SharedPreferences → AuthUnauthenticated
```

### DealBloc
```
FetchDeals   → calls DealRepository (1.2s delay) → DealLoaded
SearchDeals  → filters allDeals by name → DealLoaded (new filteredDeals)
FilterDeals  → filters allDeals by risk/industry/ROI → DealLoaded
ClearFilters → resets filteredDeals = allDeals → DealLoaded
```

### InterestBloc
```
AddInterest    → adds to list + saves IDs to SharedPreferences → InterestState
RemoveInterest → removes from list + saves IDs → InterestState
```

---

## 🧠 Key Architectural Decisions

### 1. Why BLoC?
BLoC enforces strict separation between UI and business logic. Events are the only way UI interacts with state — no direct method calls into business logic.

### 2. allDeals vs filteredDeals
The `DealLoaded` state keeps BOTH the original full list and the filtered list. This means:
- We never lose data when filters change
- All filters are composed together in a single `_applyAllFilters()` function
- Adding a new filter doesn't clear existing ones

### 3. Immutable state
Lists are never mutated. `List.from(state.list)..add(item)` creates a new list, so BLoC always detects the change.

### 4. lastAddedDealId in InterestState
This field is the trigger for the snackbar confirmation. `BlocConsumer`'s listener fires when `lastAddedDealId` changes — a clean way to handle one-time side effects.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter_bloc | ^8.1.3 | BLoC state management |
| equatable | ^2.0.5 | Compare states by value (not reference) |
| shared_preferences | ^2.2.2 | Session + interest persistence |
| fl_chart | ^0.66.2 | ROI projection line chart |
| google_fonts | ^6.1.0 | Inter font for fintech look |

---

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build release APK
flutter build apk --release
# APK path: build/app/outputs/flutter-apk/app-release.apk
```

**Demo credentials:**
```
Email:    investor@demo.com
Password: Demo@1234
```

---

## 🎨 Design Decisions

- **Dark fintech theme**: Deep navy (#071A2C) background with cyan (#00C2FF) accent — professional investment platform feel
- **Color-coded risk**: Green / Amber / Red for Low / Medium / High risk — instant visual feedback
- **Inter font**: Clean, modern, widely used in fintech apps
- **SliverAppBar**: Collapsing header on detail screen gives a native app feel
- **Dismissible**: Swipe-to-remove on Interests screen follows mobile UX conventions
- **ModalBottomSheet**: Filter panel slides up naturally on mobile




## 📸 Screenshots

### 🔐 Login Screen
![Login](screenshots/login.png)

### 📊 Deal List Screen
![Deal List](screenshots/deal_list.png)

### 📄 Deal Detail Screen
![Deal Detail](screenshots/deal_detail.png)

### My Interests Screen
![Interests](screenshots/interests.png)

