#!/bin/bash

# Project Test Agent - Automates the validation workflow
# Rule: Analyze -> Test All -> Smoke Test -> Project Run Verification

echo "🚀 Starting Project Validation Agent..."

# 1. Static Analysis
echo "🧐 Running Static Analysis..."
flutter analyze
if [ $? -ne 0 ]; then
    echo "❌ Analysis failed. Please fix warnings/errors before proceeding."
    exit 1
fi
echo "✅ Analysis Passed."

# 2. All Tests (Unit, Widget, Integration, Standards)
echo "🧪 Running All Tests..."
flutter test
if [ $? -ne 0 ]; then
    echo "❌ Some tests failed. Check logs above."
    exit 1
fi
echo "✅ All Tests Passed."

# 3. Final Verification
echo "🎉 SUCCESS: Everything is clean."
echo "👉 Now you can run the project with confidence: flutter run"
