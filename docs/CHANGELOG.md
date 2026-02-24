# Changelog

All notable changes to the Trading Framework will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/).

---

## [1.3.0] - 2026-02-24

### Added
- **Engine Configuration (core/config)**: Centralized all weights and thresholds into `EngineConfig`.
- **Repository Layer**: Added `lib/repositories/` for async I/O.
- **Determinism Lock**: Prohibited `DateTime.now()` and random values inside Services.
- **Serializable Core**: Engine evaluation now returns a serializable JSON-ready object.
- **Dynamic Scoring**: Score denominator is now derived from the sum of weights, not hardcoded.
- **Enforcement Layers**: Added rules for Tooling-level layer boundary checks and CI Coverage gates.
- **Logging Refinement**: Distinction between Info (Decision) and Debug (Full Snapshot) logging levels.

### Changed
- **UI Branding**: Standardized Grade B color to **Orange** (improved from Yellow/Orange).
- Refactored `TradingService` and `TradingController` to accommodate centralized config.

---

## [1.2.0] - 2026-02-24

### Added
- **Service Purity Rule**: Services must be pure and side-effect free.
- **Engine Versioning Rule**: All scoring changes must increment version.
- **Double Comparison**: Concrete threshold comparison using `kDoubleTolerance`.

---

## [1.1.0] - 2026-02-24

### Added
- **Riverpod Discipline**: `ref.watch` vs `ref.read` rules.
- **Lifecycle Management**: Async BuildContext safety.
- **Logging**: Integration of structured logging package.
- **Absolute Imports**: Package-only imports enforced.

---

## [1.0.0] - 2026-02-24

### Added
- Initial project structure and base standards.

---

## Probability Engine History

### Current Engine Configuration
**Effective From**: 2026-02-24  
**Engine Version**: 1.0.0 (Project v1.3.0)

| Parameter | Category | Weight |
|-----------|----------|--------|
| Trend Alignment | Technical | 3 |
| Support/Resistance | Technical | 2 |
| Volume Confirmation | Technical | 2 |
| Risk-Reward Ratio | Risk Management | 3 |
| Position Sizing | Risk Management | 2 |
| Volatility (ATR) | Market Context | 1 |
| No Impact News | Market Context | 1 |
| **Total** | | **Dynamic (Current: 14)** |

### Grade Thresholds
| Grade | Score Range | Probability Range | Executive Strategy | Color |
|-------|-----------|-------------------|--------------------|-------|
| A | 12–14 | 85.7% – 100% | Full Position Size | Green |
| B | 8–11 | 57.1% – 78.6% | 50% Position Size | Orange |
| C | 0–7 | 0.0% – 50.0% | No Trade (Wait) | Red |
