# Trade Evaluation Specification

**Engine Version**: 1.0.0 (Project v1.3.0)  
**Status**: Active  
**Effective From**: 2026-02-24  
**Domain**: Probability Scoring Engine

---

## 1. Logic Foundations

### 1.1 Rule-Based Design
*   All trade decisions must be rule-driven and deterministic.
*   **Determinism Lock**: Evaluation must not depend on system time, random values, or external mutable state. All data must be passed as inputs.
*   **Non-Goal**: The engine does not predict markets. It evaluates rule conformance only.

### 1.2 Deterministic Output
Evaluation produces a structured, **serializable** result:
*   Grade Classification (A, B, or C)
*   Probability Score (0-100%)
*   Decision Payload (JSON-compatible)

---

## 2. Evaluation Model

### 2.1 Configuration Centralization
*   All weights and thresholds are strictly defined in `lib/core/config/engine_config.dart`.
*   **Dynamic Total**: The maximum possible score is calculated at runtime as the sum of all parameter weights.

### 2.2 Hard Filters (Pre-Evaluation)
*   Must be checked first.
*   **Short-Circuit**: If a hard filter is triggered, the evaluation stops immediately. Normalized scoring is bypassed.

---

## 3. Scoring & Graduation

### 3.1 Decision Tiers
| Grade | Score Range | Probability Range | Executive Strategy | Color |
|-------|-------------|-------------------|--------------------|-------|
| **Grade A** | 12 - 14 | 85.7% – 100% | **Aggressive**: Full Size | Green |
| **Grade B** | 8 - 11 | 57.1% – 78.6% | **Conservative**: Half Size | Orange |
| **Grade C** | 0 - 7 | 0.0% – 50.0% | **Avoid**: Observation only | Red |

---

## 4. Operational Requirements

### 4.1 Traceability (Log Isolation)
*   **Services** calculate; **Controllers** log.
*   **Info Level**: Final decision only.
*   **Debug/Fine Level**: Full JSON snapshot of the evaluation for audit.

### 4.2 Change Management
Any modification to logic requires:
*   Engine version increment.
*   "ENGINE CHANGE" tag in `CHANGELOG.md`.
*   Update to `lib/core/config/engine_config.dart`.

---

## 5. Worked Example (Serializable Output)
**JSON Snapshot:**
```json
{
  "rawScore": 14,
  "percentage": 100.0,
  "grade": "Grade A",
  "decision": "High Probability (Trade Allowed)",
  "parameterSnapshots": {
    "Trend Alignment": true,
    "Support/Resistance": true,
    "Volume Confirmation": true,
    "Risk-Reward Ratio": true,
    "Position Sizing": true,
    "Volatility (ATR)": true,
    "No Impact News": true
  }
}
```
