#!/bin/bash

set -u

echo "######################################################################"
echo
echo "Building dsm" 
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

export TASN1_CFLAGS="-Ilibtasn1/include"
export TASN1_LIBS="-Llibtasn1 -ltasn1"
BUILD_FILES=""
CFLAGS=""
CONF=""

cd $DSM_DIR

for ARCH in $ARCHS
do
    echo
    echo "Building $ARCH for $SDK_PLATFORM $EFFECTIVE_PLATFORM_NAME"
    echo

	  BUILD_FILES="$BUILD_FILES build/$BUILD_PRODUCTS_DIR/$ARCH/lib/libdsm.a"

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

    export CFLAGS="-arch $ARCH -isysroot $SDKROOT -m$SDK_PLATFORM-version-min=$MIN_VERSION -fembed-bitcode -DNDEBUG -Wno-sign-compare"
    
    # ./bootstrap
    ./configure --host=$HOST  --prefix=$PWD/build/$BUILD_PRODUCTS_DIR/$ARCH && make && make install

    make clean

    echo "dsm - $PLATFORM $ARCH done."
done

echo "Build files: $BUILD_FILES"

echo "Building Universal library"

mkdir -p build/$BUILD_PRODUCTS_DIR/universal
lipo -create $BUILD_FILES -output build/$BUILD_PRODUCTS_DIR/universal/libdsm.a


echo "Copy headers"

mkdir build/$BUILD_PRODUCTS_DIR/universal/include

for ARCH in $ARCHS
do
cp -R build/$BUILD_PRODUCTS_DIR/$ARCH/include build/$BUILD_PRODUCTS_DIR/universal/
done

PRODUCTS_DIR=$BUILD/products/$BUILD_PRODUCTS_DIR

mkdir -p $PRODUCTS_DIR

echo "Store artefacts in $PRODUCTS_DIR"

# todo: broken linking if you copy built headers
cp -a build/$BUILD_PRODUCTS_DIR/universal/libdsm.a $PRODUCTS_DIR
# cp -a build/$BUILD_PRODUCTS_DIR/universal/include/. $PRODUCTS_DIR

cp -a libtasn1/libtasn1.a $PRODUCTS_DIR
# cp -a libtasn1/include/. $PRODUCTS_DIR/bdsm

cp -a $WORKING_DIR/headers/. $PRODUCTS_DIR/bdsm

cd ../
