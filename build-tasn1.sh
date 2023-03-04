#!/bin/bash

set -u

echo "######################################################################"
echo
echo "Building tasn1" 
echo "Platform: $PLATFORM"
echo "Effective platform name: $EFFECTIVE_PLATFORM_NAME"
echo "SDK platform: $SDK_PLATFORM"
echo "Build products directory: $BUILD_PRODUCTS_DIR"
echo "Architectures: $ARCHS"
echo "Min version: $MIN_VERSION"
echo "tasn1 dir: $TASN1_DIR"
echo "dsm dir: $DSM_DIR"
echo
echo "######################################################################"

BUILD_FILES=""
CFLAGS=""

cd $TASN1_DIR

for ARCH in $ARCHS
do
    echo
    echo "Building $ARCH for $SDK_PLATFORM $EFFECTIVE_PLATFORM_NAME"
    echo

	BUILD_FILES="$BUILD_FILES build/$BUILD_PRODUCTS_DIR/$ARCH/lib/libtasn1.a"

    if [[ "$SDK_PLATFORM" == "macosx" ]]; then
      CONF="no-shared"
    else
      CONF="no-asm no-hw no-shared no-async"
    fi

    if [[ "$EFFECTIVE_PLATFORM_NAME" == "-maccatalyst" ]]; then
      export CFLAGS="-target $ARCH-apple-ios13.1-macabi -Wno-overriding-t-option"
    fi

    if [[ "$SDK_PLATFORM" == "macosx" ]]; then
      if [[ "$ARCH" == "x86_64" ]]; then
        HOST="darwin64-x86_64-cc"
      elif [[ "$ARCH" == "arm64" ]]; then
        HOST="darwin64-arm64-cc"
        CONF="$CONF no-asm"
      else
        HOST="darwin-$ARCH-cc"
      fi
    else
        HOST="arm-apple-darwin"
    fi

    if [[ "${ARCH}" == *64 ]] || [[ "${ARCH}" == arm64* ]]; then
      CONF="$CONF enable-ec_nistp_64_gcc_128"
    fi

    export CROSS_TOP="$DEVELOPER/Platforms/$PLATFORM.platform/Developer"
    export CROSS_SDK="$PLATFORM.sdk"
    export SDKROOT="$CROSS_TOP/SDKs/$CROSS_SDK"
    export CC="$CLANG -arch $ARCH"
    export BITCODE_GENERATION_MODE=bitcode
    export CFLAGS="$CFLAGS -fembed-bitcode"

    if [[ "$ARCH" == "x86_64" ]]; then
      sed -ie "s!^CFLAG=!CFLAG=-isysroot $SDKROOT !" "Makefile"
    fi

    export CFLAGS="-arch $ARCH -isysroot $SDKROOT -m$SDK_PLATFORM-version-min=$MIN_VERSION -fembed-bitcode -Wno-sign-compare"
    
    ./configure --host=$HOST --prefix=$PWD/build/$BUILD_PRODUCTS_DIR/$ARCH && make && make install

    make clean

    echo "tasn1 - $PLATFORM $ARCH done."
done

echo "Build files: $BUILD_FILES"

echo "Building Universal library"

mkdir -p build/$BUILD_PRODUCTS_DIR/universal
lipo -create $BUILD_FILES -output build/$BUILD_PRODUCTS_DIR/universal/libtasn1.a

echo "Copy headers"

mkdir build/$BUILD_PRODUCTS_DIR/universal/include

for ARCH in $ARCHS
do
cp -R build/$BUILD_PRODUCTS_DIR/$ARCH/include build/$BUILD_PRODUCTS_DIR/universal/
done

DSM_DIR_LIBTASN1=$$DSM_DIR/libtasn1

echo "Copy artefacts to libdsm folder: $DSM_DIR_LIBTASN1"

cd ../
mkdir $DSM_DIR/libtasn1

cp -a $TASN1_DIR/build/$BUILD_PRODUCTS_DIR/universal/. $DSM_DIR/libtasn1
