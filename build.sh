#!/bin/sh
# For simplicity, version are hardcoded for build tools, NDK, and SDK.
# In addition, the architecture is hardcoded to AARCH64.
# Feel free to change these to your liking!
# Make sure to also edit AndroidManifest.xml if you change SDK versions
BUILD=build
JNI=lib/arm64-v8a
BUILD_TOOLS=$ANDROID_HOME/build-tools/36.0.0
ANDROID_NDK=$ANDROID_HOME/ndk/29.0.13113456
ANDROID_TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt
if [ -d "$ANDROID_TOOLCHAIN/windows-x86_64" ] ; then
	# Those who use MSYS (like me) use these variables.
	# As a bounus, it also works under busybox-w32.
	ANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN/windows-x86_64
	EXT=".bat"
else
	ANDROID_TOOLCHAIN=$ANDROID_TOOLCHAIN/linux-x86_64
	EXT=""
fi
CC=$ANDROID_TOOLCHAIN/bin/aarch64-linux-android35-clang
ANDROID_JAR=$ANDROID_HOME/platforms/android-35/android.jar
SYSROOT=$ANDROID_TOOLCHAIN/sysroot
NATIVE_APP_GLUE_DIR=$ANDROID_NDK/sources/android/native_app_glue
PLATFORM_TOOLS=$ANDROID_HOME/platform-tools

# For simplicity, project hardcoded to "barebones"
# Make sure to also edit AndroidManifest.xml if you change this
LIB=libbarebones.so
CFLAGS="-lm -lc -llog -landroid -ldl -g -Og -shared -fPIC --sysroot=$SYSROOT"
KEYSTORE=$BUILD/barebones.keystore
KEYPASS=barebones

set -e

mkdir -p $BUILD/$JNI
if [ ! -f $KEYSTORE ] ; then
	($JAVA_HOME/bin/keytool -genkeypair -validity 10000 -dname "CN=barebones,O=Android,C=ES" -keystore $KEYSTORE -storepass $KEYPASS -keypass $KEYPASS -alias barebones -keyalg RSA)
fi
$CC -I $NATIVE_APP_GLUE_DIR $NATIVE_APP_GLUE_DIR/android_native_app_glue.c main.c -o $BUILD/$JNI/$LIB $CFLAGS

# Only APKSigner out of all of these is a batch file on Windows
$BUILD_TOOLS/aapt package -f -M AndroidManifest.xml -I $ANDROID_JAR -F $BUILD/app.apk
(cd $BUILD && $BUILD_TOOLS/aapt add app.apk $JNI/$LIB)
$BUILD_TOOLS/zipalign -f 4 $BUILD/app.apk $BUILD/app-signed.apk
$BUILD_TOOLS/apksigner"$EXT" sign --ks $KEYSTORE --ks-pass pass:$KEYPASS $BUILD/app-signed.apk
