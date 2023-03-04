#!/bin/bash

set -u

# Global build settings

ROOT_PATH=$(cd "$(dirname "$0")/.."; pwd -P)
export ROOT_PATH

export WORKING_DIR="$ROOT_PATH/LIBDSM"
export BUILD=$WORKING_DIR/build

CLANG=$(xcrun --find clang)
export CLANG

DEVELOPER=$(xcode-select --print-path)
export DEVELOPER

# Source fetch

fetchSource () {
  local url=$1
  local filename=$2
  local path=$3
  local file=$BUILD/$filename

  mkdir -p "$path"
  echo "Downloading $filename"
  curl -L -S -s "$url" --output "$file"
  local md5
  md5=$(md5 -q "$file")
  echo "MD5: $md5"

  tar -zxkf "$file" -C "$path" --strip-components 1 2>&-
  rm -f "$file"
}

TASN1_TAG="4.12"
TASN1_URL="https://ftp.gnu.org/gnu/libtasn1/libtasn1-$TASN1_TAG.tar.gz"
TASN1_BUILD_DIR="$BUILD/libtasn-$TASN1_TAG"

DSM_TAG="0.3.2"
DSM_DIR_NAME="libdsm-$DSM_TAG"
DSM_URL="https://github.com/videolabs/libdsm/releases/download/v$DSM_TAG/$DSM_DIR_NAME.tar.gz"
DSM_DIR_NAME="$BUILD/$DSM_DIR_NAME"

if [[ -d "$TASN1_BUILD_DIR" ]] && [[ -d "$DSM_DIR_NAME" ]]; then
  echo "Skip... Sources already downloaded"
else
  fetchSource $TASN1_URL "libtasn" "$TASN1_BUILD_DIR"
  fetchSource $DSM_URL "libdsm" "$DSM_DIR_NAME"
fi

# Build libs

echo Remove the previous builds info
rm -rf $WORKING_DIR/LIBDSM.xcframework
rm -rf $BUILD/products
rm -rf $DSM_DIR_NAME/libtasn1
rm -rf $DSM_DIR_NAME/build
rm -rf $TASN1_BUILD_DIR/build

buildLibrary () {
  export BUILD_PRODUCTS_DIR=$1
  export SDK_PLATFORM=$2
  export PLATFORM=$3
  export EFFECTIVE_PLATFORM_NAME=$4
  export ARCHS=$5
  export MIN_VERSION=$6
  
  export TASN1_DIR=$TASN1_BUILD_DIR
  export DSM_DIR=$DSM_DIR_NAME

  "$ROOT_PATH/LIBDSM/build-tasn1.sh"
  "$ROOT_PATH/LIBDSM/build-libdsm.sh"
}

buildLibrary "iphoneos" "iphoneos" "iPhoneOS" "" "armv7 armv7s arm64" "9.0"
buildLibrary "iphonesimulator" "iphonesimulator" "iPhoneSimulator" "" "x86_64 arm64" "9.0"

# Create framework

LIB_NAME="LIBDSM"
XCFRAMEWORK_NAME="$LIB_NAME.xcframework"

TAG=$DSM_TAG
ZIPNAME="$LIB_NAME-$TAG.xcframework.zip"

FRAMEWORK="$LIB_NAME.framework"
FRAMEWORKS_DIR=$WORKING_DIR/Frameworks

createFramework () {
  rm -rf "$FRAMEWORKS_DIR/$1/$FRAMEWORK"

  mkdir -vp "$FRAMEWORKS_DIR/$1/$FRAMEWORK/Headers"
  mkdir -vp "$FRAMEWORKS_DIR/$1/$FRAMEWORK/Modules"

  cp -RL "$BUILD/products/$1/bdsm/" "$FRAMEWORKS_DIR/$1/$FRAMEWORK/Headers"
  cp "$WORKING_DIR/module.modulemap" "$FRAMEWORKS_DIR/$1/$FRAMEWORK/Modules/module.modulemap"
  cp "$BUILD/products/$1/libdsm.a" "$FRAMEWORKS_DIR/$1/$FRAMEWORK/$LIB_NAME"
  cp "$BUILD/products/$1/libtasn1.a" "$FRAMEWORKS_DIR/$1/$FRAMEWORK/$LIB_NAME"
}

createFramework "iphoneos"
createFramework "iphonesimulator"

xcodebuild -create-xcframework \
 -framework "$FRAMEWORKS_DIR/iphoneos/$FRAMEWORK" \
 -framework "$FRAMEWORKS_DIR/iphonesimulator/$FRAMEWORK" \
 -output "$XCFRAMEWORK_NAME"