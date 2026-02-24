# Trade Evaluation Specification

**Version**: 1.0.0  
**Status**: Active  
**Domain**: Probability Scoring Engine

---

## 1. Logic Foundations

### 1.1 Rule-Based Design
*   All trade decisions must be rule-driven and deterministic.
*   No emotional, discretionary, or UI-triggered hidden logic.

### 1.2 Deterministic Output
The same set of input parameters must **always** produce the same:
*   Grade Classification (A, B, or C)
*   Probability Score (0-100%)
*   Risk Rating

---

## 2. Evaluation Model

### 2.1 Parameter Categories
Evaluation parameters are strictly grouped into:
*   **Trend**: Market structure and EMA alignment.
*   **Momentum**: RSI, volume, and trigger patterns.
*   **Volatility**: ATR and market environment.
*   **Risk Management**: RR ratios and position sizing.
*   **Market Context**: News and session timing.

### 2.2 Hard Filters (Pre-Evaluation)
These overrides trigger before the scoring engine:
*   **Risk-Reward Filter**: If RR < 1:1 → Auto-Grade C.
*   **News Filter**: High-impact news active → System Rejection.

---

## 3. Scoring & Graduation

### 3.1 Raw Score Normalization
*   Raw Score Range: 0 - 14 points.
*   Percentage Formula: `(raw_score / 14) * 100` (rounded to 1 decimal).

### 3.2 Decision Tiers
| Grade | Status | Score Range | Executive Strategy |
|-------|--------|-------------|--------------------|
| **Grade A** | High Prob | 12 - 14 | **Aggressive**: Full Position Size. |
| **Grade B** | Med Prob | 8 - 11 | **Conservative**: 50% Position Size. |
| **Grade C** | Low Prob | 0 - 7 | **Avoid**: Monitoring only. |

---

## 4. Operational Requirements

### 4.1 Numeric Precision
*   Use `double` for all technical indicators.
*   Avoid `==` comparisons for price data; use threshold-based logic.

### 4.2 Traceability (Logging)
Each evaluation event must log:
*   State of every individual parameter (checked/unchecked).
*   Category-wise sub-scores.
*   Hard filter audit results.
*   Decision timestamp and final Grade.

### 4.3 Policy: No Hidden Weights
*   All weights must be explicitly defined in the source code.
*   Weight adjustments are treated as "Logic Changes" and require a version bump and backtest documentation.

---

## 5. Sample Evaluation Flow
1. **Filter Audit**: Check Hard Filters (RR, News).
2. **Category Assessment**: Score Technicals, Risk, and Context.
3. **Normalization**: Calculate final percentage and Grade.
4. **Log Event**: Store evaluation snapshot for post-trade analysis.
5. **Output**: Deliver Decision to UI.
