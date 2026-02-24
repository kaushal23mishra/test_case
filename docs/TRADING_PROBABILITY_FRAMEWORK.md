# Trading Probability Framework

This document defines the logic and scoring system used to evaluate trade setups.

## 1. Probability Percentage Model

Trading is a game of probability. This framework quantifies setups into three tiers:

| Tier | Probability | Score Range | Action |
| :--- | :--- | :--- | :--- |
| **Grade A** | > 85% | 12 - 14 | **Full Position Size** |
| **Grade B** | 60% - 85% | 8 - 11 | **Half Position Size** |
| **Grade C** | < 60% | 0 - 7 | **NO TRADE** |

## 2. Trade Scoring System

Total maximum score: **14 points**.

### A. Technical Parameters (7 Points)
*   **Trend Alignment (3 pts)**: Price position relative to 200 EMA & Structure.
*   **Key Level (2 pts)**: Proximity to Support/Resistance or Fibonacci zones.
*   **Momentum/Volume (2 pts)**: RSI trend and Volume confirmation on trigger.

### B. Risk Management (5 Points)
*   **Risk-Reward (3 pts)**: Minimum 1:2 RR available.
*   **Position Sizing (2 pts)**: Risk limited to 1% of equity.

### C. Market Conditions (2 Points)
*   **Volatility (1 pt)**: ATR allows for a logical Stop Loss.
*   **News Filter (1 pt)**: No high-impact news within 60 minutes.

## 3. Decision Checklist

Before execution, confirm:
1. [ ] Is the higher timeframe trend clear?
2. [ ] Is there a clear "Reason to Entry" (Hammer, Engulfing, etc.)?
3. [ ] Is the Stop Loss placement logical, not just wide?
4. [ ] Am I emotionally neutral about this trade?

## 4. Risk Rules
*   **Max Daily Drawdown**: 3% of total capital.
*   **Max Consecutive Losses**: Stop trading for the day after 3 losses.
*   **Correlation**: Avoid taking multiple trades in correlated pairs (e.g., Nifty & BankNifty simultaneously).
