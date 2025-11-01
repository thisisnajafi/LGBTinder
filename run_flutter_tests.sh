#!/bin/bash

# Flutter Test Runner Script
# Runs all Flutter tests with coverage reporting

set -e

echo "🧪 Running Flutter Tests..."
echo ""

# Create coverage directory if it doesn't exist
mkdir -p coverage

# Run all tests with coverage
flutter test --coverage

# Generate coverage report
echo ""
echo "📊 Generating Coverage Report..."
test_coverage

# Display coverage summary
echo ""
echo "✅ Test execution complete!"
echo ""
echo "Coverage report generated in: coverage/lcov.info"
echo "View HTML report: coverage/html/index.html"

