#!/bin/bash

# Todo Notes App Deployment Script
# This script automates the build and deployment process

set -e

echo "🚀 Starting Todo Notes App deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Flutter version:"
flutter --version

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting dependencies..."
flutter pub get

# Generate code files
print_status "Generating code files..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Analyze code
print_status "Analyzing code..."
flutter analyze

# Run tests
print_status "Running tests..."
flutter test

# Build APK
print_status "Building release APK..."
flutter build apk --release

# Build App Bundle
print_status "Building release App Bundle..."
flutter build appbundle --release

# Check if builds were successful
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    print_success "APK build successful!"
    print_status "APK location: build/app/outputs/flutter-apk/app-release.apk"
    
    # Get APK size
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    print_status "APK size: $APK_SIZE"
else
    print_error "APK build failed!"
    exit 1
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    print_success "App Bundle build successful!"
    print_status "AAB location: build/app/outputs/bundle/release/app-release.aab"
    
    # Get AAB size
    AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
    print_status "AAB size: $AAB_SIZE"
else
    print_error "App Bundle build failed!"
    exit 1
fi

print_success "🎉 Deployment completed successfully!"
print_status "You can now distribute the APK or upload the AAB to Google Play Store."

# Optional: Open build directory
if command -v open &> /dev/null; then
    print_status "Opening build directory..."
    open build/app/outputs/
elif command -v xdg-open &> /dev/null; then
    print_status "Opening build directory..."
    xdg-open build/app/outputs/
fi
