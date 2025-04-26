# android-native-app-barebones
The most elementary, stripped-down template of building an APK using Android tools

## Required Environment Variables

* __ANDROID_HOME__: Path where your [Android command line tools](https://developer.android.com/studio#command-line-tools-only) are installed
* __JAVA_HOME__:    Path where your JDK is installed
* __PATH__:         The ``bin`` folder from __JAVA_HOME__ must be included

## Required SDKManager Installations

The scripts work for the following package versions which can be installed via ``sdkmanager``

```sh
sdkmanager 'build-tools;36.0.0' 'ndk;29.0.13113456' 'platforms;android-35'
```

In addition, you should also install ``platform-tools`` via ``sdkmanager`` to use ``adb``

## Instructions

You can simply invoke ``build.sh`` or ``build.bat`` for ``/bin/sh``
or ``CMD.EXE`` respectfully and it should build ``build/app-signed.apk``

To keep the scripts simple and easy to read, the APK only is built for
AARCH64so you need a 64-bit ARM Android device handy or to emulate
such a device (caveat: this is slow to do on X86\_64).

After this, set up an ADB daemon and install ``app-signed.apk`` using ``adb``
and run it on your device. It should just be a black screen that doesn't crash.

Additionally, you can look at logs via ``adb logcat "*:S barebones"``
and you should find a nice little "hello" from the app you built.

If, for whatever reason, it's erroring out, try to look at
``adb logcat *:E``. This will usually output a java exception
from your app which lets you know why your app failed to load.
