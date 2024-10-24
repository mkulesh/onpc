[![Flutter Logo](https://github.com/mkulesh/onpc/blob/onpc-flutter/images/flutter_logo.png)](https://flutter.dev)

<img src="https://github.com/mkulesh/onpc/blob/onpc-flutter/images/icon.png" align="center" height="48" width="48">

# Enhanced Music Controller

*Enhanced AVR controller: listen to music properly!*

This app allows remote control of a Network Player or a Network A/V Receiver via the local network.
The app supports Onkyo/Pioneer/Integra released in April 2016 or later and Denon/Marantz with build-in HEOS technology.
Some TEAC models like Teac NT-503 are also supported.

This "Premium" version implements exactly the same receiver control functionality as the free version, but has some additional features:
- It is available for all desktop systems (Linux, Windows, macOS).
- The Windows version allows to define global shortcuts for volume and playback control.
- It allows to rename input channels when this feature is not supported in the firmware.
- It allows to reorder the play queue using drag-and-drop, change the font and buttons size and show/hide/reorder all control elements for all tabs.
- Android version allows to create home screen widgets.

## Versions
* [Android](https://play.google.com/store/apps/details?id=com.mkulesh.onpc.plus)
* [macOS](https://apps.apple.com/app/id1490166845)
* [iOS](https://apps.apple.com/app/id1490166845)
* [Windows](https://apps.microsoft.com/detail/9p9v57cz8jg3)

## Project structure and application build
* android - contains Android-specific code (Java) that implements home widgets, volume keys handling, network state listener.
The build script contains a signing parameter section in order to sign the target APK with a personal Google Play developer certificate that is not available on github.
To build Android app, these parameters shall be removed and build script shall be adapted: 
  - open the file `android/app/build.gradle` and comment out all parameters in sections `signingConfigs->Release` and `buildTypes->release`
  - navigate to release directory
  - open the file build-android.sh and adapt the parameter FLUTTER_PATH to the actual Flutter installation path
  - run the script build-android.sh
  - new unsigned `MusicControl-v<Version>-android.apk` shall appear in the release directory
  - in case of any Gradle problem:  
    - stop the gradle daemon: `../android/gradlew --stop`
    - remove gradle cashes in the directory `~/.gradle/caches`

* images - launcher images and screenshots

* integration_test - some app tests developed using Onkyo NS-6170

* ios - contains iOS-specific code (Swift) and XCode project settings. There is no special iOS features, only the standard iOS runner. To build iOS app:
  - ensure that a valid Apple Developer account is set in XCode for the project
  - navigate to release directory
  - open the file build-ios.sh and adapt the parameter FLUTTER_PATH to the actual Flutter installation path
  - run the script build-ios.sh
  - open the project in XCode
  - perform "archiving" of the project and than perform Ad-hoc distribution. Manually save the build into release directory 

* lib - the main platform-independent app code (Flutter). Contains following modules
  - assets - all images (usually SVG) used within the app
  - config - classes that handle the persistent configuration. On mobile, this configuration is hidden. On desktop, this configuration can be found here:
    - Linux: `~/.local/share/com.mkulesh.onpc`
    - Windows: `Users/family/AppData/Roaming/Mikhail Kulesh/Music Control`
    - macOS: `Library/Containers/com.mkulesh.onpc/Data/Library/Preferences`
  - constants: global constants (strings, themes, dimensions) used within the app
  - dialog - all dialog windows
  - iscp - network protocol implementation, receiver state and state change handling. Contains implementation for different protocols:
    - for Onkyo: Integra Serial Communication protocol (ISCP)
    - for Denon: Denon control protocol (DCP) and Denon HEOS protocol
    - messages - contains implementation for all commands send to receiver and all responses send by receiver to the app.
      Some messages are bi-directional (command and response), and some messages implement only one direction.
      Some messages are also used in one protocol (ISCP or DCP or HEOS) only, and some messages used in several protocols
    - scrips - contains some sequences of commands
    - state - contains a current receiver state. Is empty after commit and will be filled when responses from the receiver are processed.
    - StateManager.dart implements whole business-logic how to establish a connection and process commands and responses
    - all other files implement low-level communication with receiver
  - utils - some helper classes
  - views - all visual elements shown in the app. These elements are automatically updated when corresponding messages related to this view are received and processed
  - widgets - common generic visual elements used within views
  - main.dart - app entry point and main app view. Also implements communication with platform-specific code and handles app lifecycle  

* linux - contains Linux-specific code (C++) that implements save and restore of window position and size. To build Linux app:
  - ensure that necessary dependencies are installed: clang cmake ninja-build gtk3-devel xz-devel 
  - navigate to release directory
  - open the file build-linux.sh and adapt the parameter FLUTTER_PATH to the actual Flutter installation path
  - run the script build-linux.sh
  - new compressed `MusicControl-<version>-linux-x86_64.zip` and a directory `MusicControl-<version>-linux-x86_64` shall appear in the release directory

* macos - contains macOS-specific code (Swift) and XCode project settings. There is no special features, only the standard macOS runner. To build macOS app:
  - navigate to release directory
  - open the file build-macos.sh and adapt the parameter FLUTTER_PATH to the actual Flutter installation path
  - run the script build-macos.sh
  - new compressed file `MusicControl-<version>-macos.dmg.zip` shall appear in the release directory  

* release - build scripts

* res - string resources using within the app for all available translations. Stored as Android resource files. Can be converted to Flutter format using the script convert.sh

* windows - contains Windows-specific code (C++) and Visual Studio project settings. Implements keyboard shortcuts for playback control. To build Windows app:
  - navigate to release directory
  - open the file build-windows.bat and adapt the parameter FLUTTER_PATH to the actual Flutter installation path
  - run the script build-windows.bat
  - new file `MusicControl-<version>-windows-x86_64.msix` shall appear in the release directory

## License
Copyright © 2019-2023 by __Mikhail Kulesh__

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details. You should have received a copy of the GNU General Public License along with this program.

If not, see [www.gnu.org/licenses](https://www.gnu.org/licenses)

## Used Open Source Libraries
* Material Design Icons: [materialdesignicons.com](https://materialdesignicons.com)
* Material Design Palette: [www.materialpalette.com](https://www.materialpalette.com)
* Flutter: [flutter.dev](https://flutter.dev)
* Flutter packages: [pub.dev/packages](https://pub.dev/packages)

## Names
* Official app name on App Store, Google Play, and MS Store: *Enhanced Music Controller*
* Technical app name, the short name on the Home Screen, executable name: *Music Control*
* Short app description: *Enhanced AVR controller: listen to music properly!*

## Screenshots
* Playback screen in landscape orientation, 12 Inch iPad, Strong Dark theme
  <img src="https://github.com/mkulesh/onpc/blob/onpc-flutter/images/screenshots/iPad-12.9-inch-3gen/listen.png" align="center">

* Audio control in portrait orientation, 5 Inch Android phone, Light theme
  <img src="https://github.com/mkulesh/onpc/blob/onpc-flutter/images/screenshots/android-phone/audio_control.png" align="center">

* Media screen in portrait orientation, 7 Inch Android Tablet, Dark theme
  <img src="https://github.com/mkulesh/onpc/blob/onpc-flutter/images/screenshots/android-7-inch/media.png" align="center" height="800">
