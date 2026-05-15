# CI/CD — JobMatch

## Overview
- Tests run on push to `dev` and PR to `main`
- Coverage report via Codecov
- GitHub Actions on macOS runner

## Setup

### 1. Codecov
- Go to codecov.io → Sign in with GitHub
- Add JobMatch repository
- Copy CODECOV_TOKEN
- GitHub → Settings → Secrets → Actions → New secret
- Name: CODECOV_TOKEN, Value: paste token

### 2. GitHub Actions workflow
Create `.github/workflows/tests.yml`:

```yaml
name: Tests

on:
  push:
    branches: [ dev ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: macos-15
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Select Xcode
      run: sudo xcode-select -s /Applications/Xcode_16.app
    
    - name: Build and Test
      run: |
        xcodebuild test \
          -project MatchFlow.xcodeproj \
          -scheme MatchFlow \
          -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' \
          -enableCodeCoverage YES \
          -resultBundlePath TestResults.xcresult \
          | xcpretty
    
    - name: Convert coverage to lcov
      run: |
        xcrun xccov view --report --json TestResults.xcresult > coverage.json
        
    - name: Upload to Codecov
      uses: codecov/codecov-action@v4
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        files: coverage.json
        fail_ci_if_error: false
```

## Secrets needed
| Secret | Where to get |
|--------|-------------|
| CODECOV_TOKEN | codecov.io → repository settings |

## Badge for README
After Codecov setup, add to README.md:
```markdown
[![codecov](https://codecov.io/gh/Kassandra1991/MatchFlow/branch/main/graph/badge.svg)](https://codecov.io/gh/Kassandra1991/MatchFlow)
```

## Rules
- Never commit Secrets.swift — CI will fail without real keys
- Tests must not make real API calls — use mocks
- If CI fails on dev — fix before merging to main
- Keep test suite fast — target under 2 minutes total

## Troubleshooting
- Simulator not found → check iOS version in destination
- Xcode version mismatch → update macos-15 and Xcode_16.app path
- Codecov not uploading → check CODECOV_TOKEN secret
