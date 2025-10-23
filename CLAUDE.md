# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ClaudeDemo is a multi-platform SwiftUI application targeting iOS, macOS, and visionOS (xrOS). The project uses Xcode 16.3 with Swift 5.0 and supports iOS 18.4+, macOS 15.4+, and visionOS 2.4+.

## Build and Development Commands

### Building the App
```bash
# Build for all platforms (default: Release configuration)
xcodebuild -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -configuration Debug build

# Build for specific destination (iOS Simulator)
xcodebuild -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build for macOS
xcodebuild -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -destination 'platform=macOS' build
```

### Running Tests
```bash
# Run all tests
xcodebuild test -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -destination 'platform=iOS Simulator,name=iPhone 16'

# Run unit tests only
xcodebuild test -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ClaudeDemoTests

# Run UI tests only
xcodebuild test -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ClaudeDemoUITests

# Run a single test
xcodebuild test -project ClaudeDemo.xcodeproj -scheme ClaudeDemo -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ClaudeDemoTests/ClaudeDemoTests/example
```

### Clean Build
```bash
# Clean build artifacts
xcodebuild clean -project ClaudeDemo.xcodeproj -scheme ClaudeDemo
```

## Project Architecture

### Structure
- **ClaudeDemo/**: Main application target containing SwiftUI views and app logic
  - `ClaudeDemoApp.swift`: App entry point using `@main` attribute
  - `ContentView.swift`: Root view of the application
  - `Assets.xcassets/`: Image and color assets
  - `ClaudeDemo.entitlements`: App sandbox and security entitlements

- **ClaudeDemoTests/**: Unit test bundle using Swift Testing framework
- **ClaudeDemoUITests/**: UI test bundle for end-to-end testing

### Key Technical Details
- **Development Team**: 32CVVV5F7J
- **Bundle Identifier**: okeenea.ClaudeDemo
- **Testing Framework**: Swift Testing (using `@Test` macro, not XCTest)
- **UI Framework**: SwiftUI with SwiftUI previews enabled
- **Deployment Targets**:
  - iOS 18.4+
  - macOS 15.4+
  - visionOS 2.4+
- **App Sandboxing**: Enabled with read-only user-selected file access

### Build Configuration
- Two configurations: Debug and Release
- Hardened runtime enabled for security
- SwiftUI previews enabled in both configurations
- Supports multi-platform builds (iPhone, iPad, Mac, Apple Vision Pro)

## Git Workflow Notes
- Never push directly to main or staging branches
- Create feature branches with `feature/` prefix for new work
- Ensure no background servers are left running after development sessions
