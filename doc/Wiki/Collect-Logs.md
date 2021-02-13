**Note** The communication log between APP and Onkyo device may contain information 
(like Onkyo device ID) that shall not be published in Internet. Do not post or save 
this log on any public Internet resources!

**The first way: Using Developer Mode in the APP**
- Download and install the latest nightly build, for example 
https://github.com/mkulesh/onpc/raw/autobuild/autobuild/onpc-v1.23-debug.apk. 
**Note** This debug version is not signed. You may need to remove the signed version, 
installed from Google Play or F-Droid before installing this debug version.
- Open "Settings" dialog and activate the "Developer options" at the end of the settings list
- Go back to the App. An application menu (three dots on the right of toolbar) appears
- In the APP, perform the action that does not work as desired 
- Press the application menu button and select the menu "Latest logging"
- Long press on the text and than press "Select All" from context menu
- Copy this text in buffer ("Copy" from the context menu) and send it per e-mail to the developer
- Open "Settings" dialog again and DISABLE the "Developer options"

"Developer options" are only available in the debug build installed from github. 
Logging collection is disabled in the release build published on Google Play or F-Droid.

**The second way: using Android Debug Bridge**
- You can use both: a real Android device (phone or tablet) or Android Emulator. 
The steps below describe how to collect log using a real device.
- Activate "Developer Options" for your Android device as described in 
[this post](https://www.androidguys.com/tips-tools/how-to-enable-developer-options-on-your-android/) 
- Ensure that you have ADB (Android Debug Bridge) on your PC. If not, install it as described 
[here](https://developer.android.com/studio/command-line/adb)
- Switch off Onkyo device
- Close the app on Android device
- Attach Android device to PC where ADB is installed
- Ensure that you Android device is detected by ADB. Open console and enter following command:

`adb devices`

*Desired output*

`> adb devices
List of devices attached
NB1GAS3xxxxxxxxx	device
`

*Bad output*: no devices found
- Clear logging buffer using command:

`adb logcat -c`

*Note*: this command has no output

- Start the logging recording into a file with name onpc.log using:

`adb logcat -s "onpc" > onpc.log`

- Start the app on Android device, switch on the receiver and perform necessary test scenario.
- Switch off the receiver and close the app 
- Abort the log dumping: press Ctrl+C in the console where adb logcat is running
- Compress the obtained log file onpc.log and send it per Email to the developer
