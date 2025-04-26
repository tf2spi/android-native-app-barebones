@echo off

REM For simplicity, version are hardcoded for build tools, NDK, and SDK.
REM In addition, the architecture is hardcoded to AARCH64.
REM Feel free to change these to your liking!
REM Make sure to also edit AndroidManifest.xml if you change SDK versions
SET BUILD=build
SET JNI=lib\arm64-v8a
SET BUILD_TOOLS=%ANDROID_HOME%\build-tools\36.0.0
SET ANDROID_NDK=%ANDROID_HOME%\ndk\29.0.13113456
SET ANDROID_TOOLCHAIN=%ANDROID_NDK%\toolchains\llvm\prebuilt\windows-x86_64
SET CC=%ANDROID_TOOLCHAIN%\bin\clang --target=aarch64-linux-android35
SET ANDROID_JAR=%ANDROID_HOME%\platforms\android-35\android.jar
SET SYSROOT=%ANDROID_TOOLCHAIN%\sysroot
SET NATIVE_APP_GLUE_DIR=%ANDROID_NDK%\sources\android\native_app_glue
SET PLATFORM_TOOLS=%ANDROID_HOME%\platform-tools

REM For simplicity, project hardcoded to "barebones"
REM Make sure to also edit AndroidManifest.xml if you change this
SET LIB=libbarebones.so
SET CFLAGS=-lm -lc -llog -landroid -ldl -g -Og -shared -fPIC --sysroot=%SYSROOT%
SET KEYSTORE=%BUILD%\barebones.keystore
SET KEYPASS=barebones

@echo on

MKDIR %BUILD%\%JNI% 2>NUL
if not exist %KEYSTORE% (%JAVA_HOME%\bin\keytool -genkeypair -validity 10000 -dname "CN=barebones,O=Android,C=ES" -keystore %KEYSTORE% -storepass %KEYPASS% -keypass %KEYPASS% -alias barebones -keyalg RSA)
%CC% -I %NATIVE_APP_GLUE_DIR% %NATIVE_APP_GLUE_DIR%\android_native_app_glue.c main.c -o %BUILD%\%JNI%\%LIB% %CFLAGS%

%BUILD_TOOLS%\aapt package -f -M AndroidManifest.xml -I %ANDROID_JAR% -F %BUILD%\app.apk
PUSHD %BUILD%
%BUILD_TOOLS%\aapt add app.apk %JNI:\=/%/%LIB%
POPD
%BUILD_TOOLS%\zipalign -f 4 %BUILD%\app.apk %BUILD%\app-signed.apk
%BUILD_TOOLS%\apksigner sign --ks %KEYSTORE% --ks-pass pass:%KEYPASS% %BUILD%\app-signed.apk
