# Flutter Test Runner Script (PowerShell)
# Runs all Flutter tests with coverage reporting

Write-Host "🧪 Running Flutter Tests..." -ForegroundColor Cyan
Write-Host ""

# Create coverage directory if it doesn't exist
if (-not (Test-Path "coverage")) {
    New-Item -ItemType Directory -Path "coverage" | Out-Null
}

# Run all tests with coverage
flutter test --coverage

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "❌ Tests failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

# Generate coverage report
Write-Host ""
Write-Host "📊 Generating Coverage Report..." -ForegroundColor Cyan
test_coverage

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "⚠️  Coverage report generation failed" -ForegroundColor Yellow
}

# Display coverage summary
Write-Host ""
Write-Host "✅ Test execution complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Coverage report generated in: coverage/lcov.info"
Write-Host "View HTML report: coverage/html/index.html"

