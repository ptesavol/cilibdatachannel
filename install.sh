#!/bin/bash

set -e

# Check if VCPKG_ROOT is set and points to the correct directory
if [ -z "$VCPKG_ROOT" ]; then
    echo "Error: VCPKG_ROOT is not set. Please run 'source install-prerequisities.sh' or 'source setenvs.sh' before running this script."
    exit 1
fi

EXPECTED_VCPKG_ROOT="$(pwd)/vcpkg"
if [ "$VCPKG_ROOT" != "$EXPECTED_VCPKG_ROOT" ]; then
    echo "Error: VCPKG_ROOT points to the vcpkg of another project '$VCPKG_ROOT'. Please run 'source install-prerequisities.sh' or 'source setenvs.sh' before running this script."
    exit 1
fi

# Check if VCPKG_OVERLAY_TRIPLETS is set
if [ -z "$VCPKG_OVERLAY_TRIPLETS" ]; then
    echo "Error: VCPKG_OVERLAY_TRIPLETS is not set. Please set it to the path of the triplets directory."
    exit 1
fi

# Parse command-line options
PROD_BUILD=false
TARGET_TRIPLET=""
CHAINLOAD_TOOLCHAIN_FILE=""
PLATFORM=""
ANDROID_ABI="arm64-v8a"
ANDROID_PLATFORM=24

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --prod) PROD_BUILD=true ;;
        --ios) TARGET_TRIPLET="arm64-ios"; CHAINLOAD_TOOLCHAIN_FILE="$(pwd)/overlaytriplets/arm64-ios.cmake"; PLATFORM="OS64"; CREATE_XCFRAMEWORK=true ;;
        --android) TARGET_TRIPLET="arm64-android"; CHAINLOAD_TOOLCHAIN_FILE="$ANDROID_NDK/build/cmake/android.toolchain.cmake";;
        *) echo "Unknown parameter passed: $1. Usage: ./install.sh [--prod] [--ios] [--android]"; exit 1 ;;
    esac
    shift
done

# Set build type based on the --prod flag
if [ "$PROD_BUILD" = true ]; then
    BUILD_TYPE="Release"
else
    BUILD_TYPE="Debug"
fi

# Print the target platform if specified
if [ -n "$TARGET_TRIPLET" ]; then
    export PLATFORM=$PLATFORM
    echo "Target platform: $TARGET_TRIPLET"
fi

export CC=$(brew --prefix)/bin/clang
export CXX=$(brew --prefix)/bin/clang++

if [ -n "$TARGET_TRIPLET" ]; then
    vcpkg install --x-install-root=build/vcpkg_installed --triplet=$TARGET_TRIPLET || cat /Users/runner/work/cilibdatachannel/cilibdatachannel/vcpkg/buildtrees/libdatachannel/config-arm64-osx-out.log
else
    vcpkg install --x-install-root=build/vcpkg_installed || cat /Users/runner/work/cilibdatachannel/cilibdatachannel/vcpkg/buildtrees/libdatachannel/config-arm64-osx-out.log
fi
